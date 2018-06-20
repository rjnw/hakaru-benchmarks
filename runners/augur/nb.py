from pyaugur.augurlib import AugurOpt, AugurInfer
import numpy as np
import scipy as sp
import scipy.stats as sps
import time

# K = length(topic_prior)
# D = size(z)
# N = map number-of-word documents
# w[d] = words in document d

# from file
# at line n in docs file = same line word in words file


augur_nb = '''(K : Int, D : Int, N : Int, topic_prior : Vec Real, word_prior : Vec Real, doc : Vec Int) => {
  param theta ~ Dirichlet(topic_prior);
  param phi[k] ~ Dirichlet(word_prior)
      for k <- 0 until K ;
  param z[d] ~ Categorical(theta)
      for d <- 0 until D ;
  data w[n] ~ Categorical(phi[z[doc[n]]])
      for n <- 0 until N;
}
'''
  # data w[d, n] ~ Categorical(phi[z[d]])
  #     for d <- 0 until D, n <- 0 until N[d] ;

sched1 = 'ConjGibbs [theta] (*) ConjGibbs [phi] (*) DiscGibbs [z]'

def run_nb(words, docs, topics, out):
    def log_snapshot(tim, num_samples, z):
        out.write("%.3f" % tim)
        out.write(' ')
        out.write(str(num_samples))
        out.write(' ')
        out.write('['+' '.join([str(n) for n in z]) + ']')
        out.write('\t')


    num_docs = 1+docs[-1]
    num_words=1+max(words)
    num_topics=1+max(topics)

    topic_prior = np.full(num_topics, 1.0)
    word_prior = np.full(num_words, 1.0)

    with AugurInfer('config.yml', augur_nb) as infer_obj:
        augur_opt = AugurOpt(cached=False, target='cpu', paramScale=None)
        infer_obj.set_compile_opt(augur_opt)
        infer_obj.set_user_sched(sched1)
        init_time = time.clock()
        infer_obj.compile(num_topics, num_docs, len(words), topic_prior, word_prior, np.array(docs))(np.array(words))
        num_samples = 1
        tim = 0
        while num_samples <= 1 or tim < 1:
            tim = time.clock() - init_time
            z = infer_obj.samplen(burnIn=0, numSamples=1)['z'][0]
            log_snapshot(tim, num_samples, z)
            num_samples += 1
        out.write('\n')

news_dir = '../../input/news/'
words_file=news_dir+'words'
docs_file=news_dir+'docs'
topics_file=news_dir+'topics'

def loadNewsFile(fname) :
    with open(fname) as inp:
        raw=inp.readlines()
    return map(int, raw)

def doc_word(docs, words):
    arr = []
    ci = 0
    doc = []
    for (d,w) in zip(docs, words):
        if d == ci:
            doc.append(w)
            ci=d
        else:
            ci=d
            ndoc=np.array(doc, dtype=np.int32)
            arr.append(ndoc)
            doc=[w]
    return np.array(arr, dtype=np.int32)

if __name__ == '__main__':
    words=loadNewsFile(words_file)
    docs=loadNewsFile(docs_file)
    topics=loadNewsFile(topics_file)
    print 'loaded news...'
    with open('../../output/NaiveBayesGibbs/augur/news', 'w') as out:
        run_nb(words, docs, topics, out)
