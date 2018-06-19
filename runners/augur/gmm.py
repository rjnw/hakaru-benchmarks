from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import sys
from ast import literal_eval
import time


augur_mvgmm = '''
(K : Int, N : Int, a : Vec Real) => {
  param theta ~  Dirichlet(a) ;
  param phi[k] ~ Normal(0.0, 196)
      for k <- 0 until K ;
  param z[n] ~ Categorical(theta)
      for n <- 0 until N ;
  data t[n] ~ Normal(phi[z[n]], 1.0)
      for n <- 0 until N ;
}
'''

def run_gmm(classes, points, t, out):
    def log_snapshot(num_samples, z):
        out.write("%.3f" % t)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('['+' '.join([str(n) for n in samples]) + ']')
        out.write('\t')

    with AugurInfer('config.yml', augur_mvgmm) as infer_obj:
        # Compile
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched('ConjGibbs [phi] (*) DiscGibbs [z]')

        init_time = time.clock()
        infer_obj.compile(points,classes, np.array([1.0]*classes))(np.array(t))

        num_samples = 1
        t = 0
        while t < 20:
            t = time.clock() - init_time
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            log_snapshot(t, z)
            num_samples += 1
        out.write('\n')
    error()

if __name__ == '__main__':
    classes = sys.argv[1]
    points = sys.argv[2]
    with open('../../input/GmmGibbs/'+classes+'-'+points) as inp:
        with open('../../output/GmmGibbs/augur/'+classes+'-'+points, 'w') as out:
            for line in iter(inp.readline, ''):
                (t, z) = literal_eval(line)
                run_gmm(int(classes), int(points), t, out)
    print 'args', sys.argv
    print classes, points
