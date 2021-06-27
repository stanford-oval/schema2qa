# Run Schema2QA/AutoQA Data Synthesis, Train, and Evaluate a Parser

## Configuration

Edit `Makefile`, set `geniedir` to where Genie toolkit is installed, and set `developer_key`
to your Thingpedia developer key.
A Thingpedia developer account is required to obtain the developer key.
[Register an Almond account](https://almond.stanford.edu/user/register) and [sign up as a developer](https://almond.stanford.edu/user/request-developer),
then you can retrieve the developer key from your [user profile](https://almond.stanford.edu/user/profile) page

You can also create a file called 'config.mk' with your settings if you don't
want to edit the Makefile directly.

## Data Synthesis

### Schema2QA

To synthesize a Schema2QA dataset, i.e. a dataset that includes synthesized data and human paraphrases, simply run the following

```bash
make datadir
```

By default, it generates dataset for `restaurants` domain, with manual annotations
by the authors, and human paraphrase data by crowd workers.

To synthesize data for a different domain, set the `experiment` option as follows:

```bash
make datadir experiment=people # change this to the domain you want
```

### AutoQA (w/o automatic paraphrasing)

To synthesize an AutoQA dataset, i.e. a dataset with neither manual annotation nor human paraphrases, run the command with additional options to enable AutoQA and exclude human paraphrases as follows:

```bash
make datadir experiment=people annotation=auto human_paraphrase=false auto_paraphrase=true
```

If the command failed because misconfiguration or missing library, run `make clean` before you
rerun `make datadir`.

### AutoQA (w/ automatic paraphrasing)

You can automatically paraphrase any dataset using a neural paraphrasing model. If you paraphrase the dataset from the previous step, you will obtain the fully automatic dataset described in the [AutoQA](https://almond-static.stanford.edu/papers/autoqa-emnlp2020.pdf) paper.

Running the following command will paraphrase the dataset in `datadir` and write two resulting datasets into `datadir_paraphrased` and `datadir_filtered`. The latter is the former after filtering is applied.

```bash
make datadir_filtered
```

`datadir_paraphrased` folder will contain an additional file `almond_paraphrase.results.json`, which includes the average self-BLEU score of paraphrased examples (the lower the self-BLEU, the more different the paraphrases are from the original dataset). Another file is `almond_paraphrase.tsv` which contains the raw output of the automatic paraphraser; its two columns are example id and  the paraprhased sentence).

`datadir_filtered` folder will contain `pass-rate.json`which contains the percentage of paraphrases that passed through the filter.

## Training

To train a parser for Schema2QA, simply run

```bash
make train datadir=datadir
```

For training a parser on the AutoQA dataset, you can run `make train datadir=datadir_filtered`

Similar to `make datadir`, one can append `experiment` option to the training command to choose a different domain other than `restaurants`.

This automatically trains the BART model proposed in [SKIM](https://arxiv.org/abs/2009.07968),
which is currently the state-of-the-art model on Schema2QA benchmark.
The default setting is under `train_nlu_flags` in the Makefile. You can either tweak
the hyperparameters directly, or append additional flags using `custom_train_nlu_flags`.

## Evaluation

Once a model is trained, one can run the following command to evaluate the model on the dev set.

```
make evaluation
```

Again, set `experiment` to the domain you would like to evaluate on.

The results will be saved in a file called `${experiment}/eval/${model-name}.results`. This is a CSV
file with the following columns:

- complexity (number of properties in the query)
- number of examples
- exact match accuracy
- accuracy ignoring parameter values
- accuracy at identifying the right tables
- accuracy at identifying the right skill
- accuracy at identifying the number of tables
- syntax and type-checking accuracy

The exact match accuracy is the one reported in the paper and on the leader board.

# Compute Requirements

Data synthesis for Schema2QA can be done on a CPU machine, and usually takes less than 1 hour.

However, synthesizing an AutoQA dataset (w/ or w/o automatic paraphrasing), requires GPUs as it involves running a neural paraphraser and training and running a parser for filtering. Depending on the GPU, this can take a couple of hours.

Training a parser with default hyperparameters takes around 5 hours on our GPUs.

We have tested these commands on an AWS p3.2xlarge machine, which has one 16GB NVIDIA V100 GPU, 8 vCPUs, and 61 GiB of memory. These commands should run out-of-the-box on machines with lower CPU and RAM, but if you are using a GPU with less memory, you might need to decrease `train_batch_tokens` and `val_batch_tokens`accordingly and increase `train_iterations`and `train_filter_iterations` instead.
