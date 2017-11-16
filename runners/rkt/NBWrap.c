#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef struct aprob{
  uint64_t size;
  double *data;
}aprob;
typedef struct anat{
  uint64_t size;
  uint64_t *data;
}anat;

extern uint64_t prog(aprob*, aprob*, anat*, anat*, anat*, u_int64_t);

int main () {
  FILE *wordsf = fopen("../../input/news/words", "r");
  FILE *docsf = fopen("../../input/news/docs", "r");

  int num_docs = 19996;
  int num_words = 59967;
  int num_topics = 20;

  uint64_t *words = (uint64_t*)malloc(sizeof(uint64_t)*2435579);
  uint64_t *docs =  (uint64_t*)malloc(sizeof(uint64_t)*19997);
  for (int i = 0; i < 2435579; i++) {
    fscanf(wordsf, "%d", &words[i]);
  }
  for (int i = 0; i < 19997; i++) {
    fscanf(docsf, "%d", &docs[i]);
  }
  double* topic_prior = malloc(sizeof(double)*num_topics);
  double* word_prior = malloc(sizeof(double)*num_words);
  uint64_t *z = malloc(sizeof(uint64_t)*num_topics);

  for (int i = 0; i < num_topics; i++){
    topic_prior[i] = 0;
    z[i] = 0;
  }
  for (int i = 0; i < num_words; i++){
    word_prior[i] = 0;
  }

  struct aprob *tp = malloc(sizeof(aprob));
  tp->data = topic_prior;
  tp->size = num_topics;

  struct aprob *wp = malloc(sizeof(aprob));
  wp->data = word_prior;
  wp->size = num_words;

  struct anat *word_arr = malloc(sizeof(anat));
  word_arr->data = words;
  word_arr->size = 2435579;
  struct anat *doc_arr = malloc(sizeof(anat));
  doc_arr->data = docs;
  doc_arr->size = 19997;
  struct anat *z_arr = malloc(sizeof(anat));
  z_arr->data = z;
  z_arr->size = num_topics;
  printf("prog: ~a\n", prog(tp, wp, z_arr, word_arr, doc_arr, 0));
  return 0;
}
