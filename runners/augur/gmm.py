from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import sys
from ast import literal_eval
import time


augur_mvgmm = '''
(classes : Int, points : Int, s : Real, a : Vec Real) => {
  param theta ~  Dirichlet(a) ;
  param phi[k] ~ Normal(0.0, 196.0)
      for k <- 0 until classes;
  param z[n] ~ Categorical(theta)
      for n <- 0 until points ;
  data t[n] ~ Normal(phi[z[n]], 1.0)
      for n <- 0 until points ;
}
'''

def run_gmm(classes, points, t, out):
    def log_snapshot(tim, num_samples, z):
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('['+' '.join([str(n) for n in z]) + ']')
        out.write('\t')

    with AugurInfer('config.yml', augur_mvgmm) as infer_obj:
        # Compile
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched('DiscGibbs [z]')

        init_time = time.clock()
        infer_obj.compile(classes, points, (1.0/14)**2, np.array([1.0]*classes))(np.array(t))
        compile_time = time.clock()- init_time
        init_time = time.clock()
        infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
        num_samples = 1
        tim = 0
        while tim < 15:
            tim = time.clock() - init_time
            for i in range(5):
                infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            log_snapshot(tim, num_samples, z)
            num_samples += 5
        out.write('\n')
    # error()

if __name__ == '__main__':
    classes = sys.argv[1]
    points = sys.argv[2]
    with open('../../input/GmmGibbs/'+classes+'-'+points) as inp:
        with open('../../output/GmmGibbs/augur/'+classes+'-'+points, 'w') as out:
            for line in iter(inp.readline, ''):
                (t, z) = literal_eval(line)
                run_gmm(int(classes), int(points), t, out)
