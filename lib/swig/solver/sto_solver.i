// License: BSD 3 clause

%include <std_shared_ptr.i>

%{
#include "tick/solver/sto_solver.h"
#include "tick/base_model/model.h"
%}

%include "array_module.i"
%include "model.i"
%include "prox_module.i"

// Type of randomness used when sampling at random data points
enum class RandType {
    unif = 0,
    perm
};

template <class T, class K = T>
class TStoSolver {
 public:
  TStoSolver(
    unsigned long epoch_size,
    T tol,
    RandType rand_type
  );
  virtual void solve();

  virtual void get_minimizer(Array<T> &out);
  virtual void get_iterate(Array<T> &out);
  virtual void set_starting_iterate(Array<K> &new_iterate);

  inline void set_tol(T tol);
  inline T get_tol() const;
  inline void set_epoch_size(unsigned long epoch_size);
  inline unsigned long get_epoch_size() const;
  inline void set_rand_type(RandType rand_type);
  inline RandType get_rand_type() const;
  inline void set_rand_max(unsigned long rand_max);
  inline unsigned long get_rand_max() const;

  virtual void set_model(std::shared_ptr<TModel<T, K> > model);
  virtual void set_prox(std::shared_ptr<TProx<T, K> > prox);
  void set_seed(int seed);
};

%rename(TStoSolverDouble) TStoSolver<double>;
class TStoSolver<double> {
 // Base abstract for a stochastic solver
 public:
  TStoSolverDouble(
    unsigned long epoch_size,
    double tol,
    RandType rand_type
  );

  virtual void solve();
  virtual void get_minimizer(ArrayDouble &out);
  virtual void get_iterate(ArrayDouble &out);
  virtual void set_starting_iterate(ArrayDouble &new_iterate);

  inline void set_tol(double tol);
  inline double get_tol() const;
  inline void set_epoch_size(unsigned long epoch_size);
  inline unsigned long get_epoch_size() const;
  inline void set_rand_type(RandType rand_type);
  inline RandType get_rand_type() const;
  inline void set_rand_max(unsigned long rand_max);
  inline unsigned long get_rand_max() const;

  virtual void set_model(ModelDoublePtr model);
  virtual void set_prox(ProxDoublePtr prox);
  void set_seed(int seed);
};
typedef TStoSolver<double> TStoSolverDouble;

%rename(TStoSolverFloat) TStoSolver<float>;
class TStoSolver<float> {
 // Base abstract for a stochastic solver
 public:
  TStoSolverFloat(
    unsigned long epoch_size,
    float tol,
    RandType rand_type
  );

  virtual void solve();

  virtual void get_minimizer(ArrayFloat &out);
  virtual void get_iterate(ArrayFloat &out);
  virtual void set_starting_iterate(ArrayFloat &new_iterate);

  inline void set_tol(float tol);
  inline float get_tol() const;
  inline void set_epoch_size(unsigned long epoch_size);
  inline unsigned long get_epoch_size() const;
  inline void set_rand_type(RandType rand_type);
  inline RandType get_rand_type() const;
  inline void set_rand_max(unsigned long rand_max);
  inline unsigned long get_rand_max() const;

  virtual void set_model(ModelFloatPtr model);
  virtual void set_prox(ProxFloatPtr prox);
  void set_seed(int seed);
};
typedef TStoSolver<float> TStoSolverFloat;

%rename(AtomicStoSolverDouble) TStoSolver<double, std::atomic<double> >;
class TStoSolver<double, std::atomic<double> > {
 // Base abstract for a stochastic solver
 public:
  AtomicStoSolverDouble(
    unsigned long epoch_size,
    double tol,
    RandType rand_type
  );

  virtual void solve();
  virtual void get_minimizer(ArrayDouble &out);
  virtual void get_iterate(ArrayDouble &out);
  virtual void set_starting_iterate(ArrayAtomicDouble &new_iterate);

  inline void set_tol(double tol);
  inline double get_tol() const;
  inline void set_epoch_size(unsigned long epoch_size);
  inline unsigned long get_epoch_size() const;
  inline void set_rand_type(RandType rand_type);
  inline RandType get_rand_type() const;
  inline void set_rand_max(unsigned long rand_max);
  inline unsigned long get_rand_max() const;

  virtual void set_model(std::shared_ptr<TModel<double, std::atomic<double>> > model);
  virtual void set_prox(std::shared_ptr<TProx<double, std::atomic<double> > > prox);

  void set_seed(int seed);
};
typedef TStoSolver<double, std::atomic<double> > AtomicSAGADouble;

%rename(AtomicStoSolverFloat) TStoSolver<float, std::atomic<float> >;
class TStoSolver<float, std::atomic<float> > {
 // Base abstract for a stochastic solver
 public:
  AtomicStoSolverFloat(
    unsigned long epoch_size,
    float tol,
    RandType rand_type
  );

  virtual void solve();

  virtual void get_minimizer(ArrayFloat &out);
  virtual void get_iterate(ArrayFloat &out);
  virtual void set_starting_iterate(Array<std::atomic<float>> &new_iterate);

  inline void set_tol(float tol);
  inline float get_tol() const;
  inline void set_epoch_size(unsigned long epoch_size);
  inline unsigned long get_epoch_size() const;
  inline void set_rand_type(RandType rand_type);
  inline RandType get_rand_type() const;
  inline void set_rand_max(unsigned long rand_max);
  inline unsigned long get_rand_max() const;

  virtual void set_model(std::shared_ptr<TModel<float, std::atomic<float>> > model);
  virtual void set_prox(std::shared_ptr<TProx<float, std::atomic<float> > > prox);
  void set_seed(int seed);
};
typedef TStoSolver<float, std::atomic<float> > AtomicStoSolverFloat;

