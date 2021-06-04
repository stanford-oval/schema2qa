# Schema2QA 2.0

## Overview
The Schema2QA question answering dataset consists of natural questions over 6 different domains: 
restaurants, hotels, people, movies, books, and music. 
The evaluation sentences are collected from crowd workers with prompt containing 
only what the domain is and what properties are supported. Thus, the sentences are natural 
and diverse. They also contain entities unseen during training. 
The collected sentences are manually annotated with 
[ThingTalk](https://wiki.almond.stanford.edu/en/thingtalk) language. 

On the other hand, the training set is generated by 
[Genie](https://github.com/stanford-oval/genie-toolkit) based on crawled Schema.org metadata 
from 6 different websites (Yelp, Hyatt, LinkedIn, IMDb, Goodreads, and last.fm.) 
It's a combination of high-quality synthetic data and
a small fraction of human paraphrase data. 

## What's new in 2.0
The main difference is that all the examples in the dataset has been reannotated 
with ThingTalk 2.0. This is a major redesign of the language to make it more accessible,
less verbose, and more compatible with pre-trained neural network. 
More details about the changes can be found in the [release history](https://github.com/stanford-oval/thingtalk/blob/master/HISTORY.md).
The synthetic data is regenerated with latest Genie (v.0.8.0) using the ThingTalk 2.0, 
with improvement over both quality and efficiency. 
There are also minor annotation fixes, duplicated examples removed in the evaluation set. 
So the size of evaluation set is actually smaller, but the diversity remains the same. 

You can still find information about Schema2QA 1.0 [here](./doc/1.0.md).
However, we do not recommend using Schema2QA 1.0 any more as it contains outdated ThingTalk 
annotation. 

## Download links
Validation data can be found under directories of each domain.
The training sets can be downloaded from the following links:
- [Schema2QA training set](https://almond-static.stanford.edu/research/schema2qa2.0/autoqa.tar.xz)
- [AutoQA training set](https://almond-static.stanford.edu/research/schema2qa2.0/schema2qa.tar.xz)

Schema2QA training set contains examples synthesized with manual annotations as well as 
human paraphrase, while AutoQA training set is fully synthesized with automatically generated 
annotations and neural paraphrases using [AutoQA](https://almond-static.stanford.edu/papers/autoqa-emnlp2020.pdf). 
Both datasets are augmented with the same parameter value dataset. 

On average, for each domain, there are over 350K examples for training, 420 and 440 for dev and test, respectively.
More detailed statistics of Schema2QA dataset can be found in [stats.md](doc/stats.md).

## Leader board 
All numbers are evaluated on the Schema2QA test set which is not included in this repository. 
Please contact us at mobisocial@lists.stanford.edu to evaluate your model(s) on the test data.
Accuracy on dev set can be found in [dev.md](doc/dev.md)
Note that the accuracy is now different from what we reported in our papers as the dataset has changed. 
#### Schema2QA
|                                                                                 | restaurants | people | movies | books | music | hotels | average |
| --------------------------------------------------------------------------------| ----------- | ------ | ------ | ----- | ----- | ------ | ------- |
| [BART](https://arxiv.org/pdf/2009.07968.pdf)                                    | 73.3%       | 80.0%  | 81.7%  | 72.5% | 70.3% | 69.5%  | 74.5%   |
| [BERT-LSTM](https://almond-static.stanford.edu/papers/schema2qa-cikm2020.pdf)   | TBU%       | TBU%  | TBU%  | TBU% | TBU% | TBU%  | TBU%   |

#### AutoQA
|                                                                                 | restaurants | people | movies | books | music | hotels | average |
| --------------------------------------------------------------------------------| ----------- | ------ | ------ | ----- | ----- | ------ | ------- |
| [BART](https://arxiv.org/pdf/2009.07968.pdf)                                    | 77.3%       | 76.2%  | 83.4%  | 65.1% | 62.9% | 72.2%  | 72.9%   |
| [BERT-LSTM](https://almond-static.stanford.edu/papers/schema2qa-cikm2020.pdf)   | 62.6%       | 58.4%  | 60.4%  | 44.0% | 50.3% | 60.4%  | 56.0%   |


 
## Run synthesis and evaluation
This repository also contains the Makefile to run the full data synthesis, training, 
and evaluation of Schema2QA dataset. 
Detailed instructions can be found in [install.md](./doc/install.md) and [run.md](./doc/run.md).

## License
The dataset is released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Please cite the following papers if use this dataset in your work:
```bib
% evaluation and human paraphrase data
@inproceedings{xu2020schema2qa,
  title={Schema2QA: High-Quality and Low-Cost Q\&A Agents for the Structured Web},
  author={Xu, Silei and Campagna, Giovanni and Li, Jian and Lam, Monica S},
  booktitle={Proceedings of the 29th ACM International Conference on Information \& Knowledge Management},
  pages={1685--1694},
  year={2020}
}

% auto paraphrase data
@inproceedings{xu2020autoqa,
  title={AutoQA: From Databases to Q\&A Semantic Parsers with Only Synthetic Training Data},
  author={Xu, Silei and Semnani, Sina and Campagna, Giovanni and Lam, Monica},
  booktitle={Proceedings of the 2020 Conference on Empirical Methods in Natural Language Processing (EMNLP)},
  pages={422--434},
  year={2020}
}

% BART model
@article{campagna2020skim,
  title={SKIM: Few-Shot Conversational Semantic Parsers with Formal Dialogue Contexts},
  author={Campagna, Giovanni and Semnani, Sina J and Kearns, Ryan and Sato, Lucas Jun Koba and Xu, Silei and Lam, Monica S},
  journal={arXiv preprint arXiv:2009.07968},
  year={2020}
}
```
