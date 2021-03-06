// License: BSD 3 clause

#include "tick/solver/asaga.h"

template <class T>
AtomicSAGA<T>::AtomicSAGA(ulong epoch_size, ulong _iterations, T tol,
                          RandType rand_type, T step, int seed, int n_threads)
    : TBaseSAGA<T, T>(epoch_size, tol, rand_type, step, seed),
      n_threads(n_threads),
      iterations(_iterations),
      objective(_iterations),
      history(_iterations) {
  un_threads = (size_t)n_threads;
}

template <class T>
void AtomicSAGA<T>::initialize_solver() {
  ulong n_samples = model->get_n_samples();
  gradients_memory = Array<std::atomic<T>>(n_samples);
  gradients_average = Array<std::atomic<T>>(model->get_n_coeffs());
  gradients_memory.fill(0);
  gradients_average.fill(0);
  solver_ready = true;
}

template <class T>
void AtomicSAGA<T>::solve_dense(bool use_intercept, ulong n_features) {
  TICK_ERROR("ASAGA should not be used with dense arrays");
}

template <class T>
void AtomicSAGA<T>::solve_sparse_proba_updates(bool use_intercept, ulong n_features) {
  // Data is sparse, and we use the probabilistic update strategy
  // This means that the model is a child of ModelGeneralizedLinear.
  // The strategy used here uses non-delayed updates, with corrected
  // step-sizes using a probabilistic approximation and the
  // penalization trick: with such a model and prox, we can work only inside the
  // current support (non-zero values) of the sampled vector of features

  T n_samples = model->get_n_samples();
  T n_samples_inverse = 1 / n_samples;

  ulong n_records = std::ceil(static_cast<double>(iterations) / record_every);
  history = ArrayDouble(n_records);
  iterates_history = Array2d<T>(n_records, model->get_n_coeffs());

  auto lambda = [&](uint16_t n_thread) {
    T x_ij = 0;
    T step_correction = 0;
    T grad_factor_diff = 0, grad_avg_j = 0;
    T grad_i_factor = 0, grad_i_factor_old = 0;
    auto start = std::chrono::steady_clock::now();

    ulong idx_nnz = 0;
    int thread_epoch_size = epoch_size / n_threads;

    for (ulong t = 0; t < thread_epoch_size * iterations; ++t) {
      // Get next sample index
      ulong i = get_next_i();
      // Sparse features vector
      BaseArray<T> x_i = model->get_features(i);
      grad_i_factor = model->grad_i_factor(i, iterate);
      grad_i_factor_old = gradients_memory[i].load();

      while (!gradients_memory[i].compare_exchange_weak(grad_i_factor_old,
                                                        grad_i_factor)) {
      }

      grad_factor_diff = grad_i_factor - grad_i_factor_old;
      for (idx_nnz = 0; idx_nnz < x_i.size_sparse(); ++idx_nnz) {
        // Get the index of the idx-th sparse feature of x_i
        ulong j = x_i.indices()[idx_nnz];
        x_ij = x_i.data()[idx_nnz];
        grad_avg_j = gradients_average[j].load();
        // Step-size correction for coordinate j
        step_correction = steps_correction[j];

        while (!gradients_average[j].compare_exchange_weak(
            grad_avg_j,
            grad_avg_j + (grad_factor_diff * x_ij * n_samples_inverse))) {
        }

        // Prox is separable, apply regularization on the current coordinate
        iterate[j] = casted_prox->call_single(
            iterate[j] - (step * (grad_factor_diff * x_ij +
                                  step_correction * grad_avg_j)),
            step * step_correction);
      }
      // And let's not forget to update the intercept as well. It's updated at
      // each step, so no step-correction. Note that we call the prox, in order
      // to be consistent with the dense case (in the case where the user has
      // the weird desire to to regularize the intercept)
      if (use_intercept) {
        iterate[n_features] -=
            step * (grad_factor_diff + gradients_average[n_features]);
        T gradients_average_j = gradients_average[n_features];
        while (!gradients_average[n_features].compare_exchange_weak(
            gradients_average_j,
            gradients_average_j + (grad_factor_diff / n_samples))) {
        }
        casted_prox->call_single(n_features, iterate, step, iterate);
      }

      if (n_thread == 0 && t % (thread_epoch_size * record_every) == 0) {
        int64_t index = t / (thread_epoch_size * record_every);
        auto end = std::chrono::steady_clock::now();
        history[index] =
            ((end - start).count()) * std::chrono::steady_clock::period::num /
            static_cast<double>(std::chrono::steady_clock::period::den);
        for (ulong j = 0; j < iterate.size(); ++j) {
          iterates_history(index, j) = iterate[j];
        }
      }
    }
  };

  std::vector<std::thread> threads;
  for (size_t i = 0; i < un_threads; i++) {
    threads.emplace_back(lambda, i);
  }
  for (size_t i = 0; i < un_threads; i++) {
    threads[i].join();
  }

  TStoSolver<T, T>::t += epoch_size;
}

template class DLL_PUBLIC AtomicSAGA<double>;
template class DLL_PUBLIC AtomicSAGA<float>;
