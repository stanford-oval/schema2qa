# Run Schema2QA Synthesis, Training, and Evaluation

## Configuration
Edit `Makefile`, set `geniedir` to where Genie toolkit is installed, and set `developer_key` 
to your Thingpedia developer key. 
A Thingpedia developer account is required to obtain the developer key. 
[Register an Almond account](https://almond.stanford.edu/user/register) 
and [sign up as a developer](https://almond.stanford.edu/user/request-developer), 
then you can retrieve the developer key 
from your [user profile](https://almond.stanford.edu/user/profile) page

You can also create a file called 'config.mk' with your settings if you don't
want to edit the Makefile directly.

## Synthesis
To synthesize the dataset, simply run the following
```bash
make datadir
```
By default, it generates dataset for `restaurants` domain, with manual annotations 
by the authors, and human paraphrase data by crowd workers.

To synthesize data for a different domain, set the `experiment` option as follows:
```bash
make datadir experiment=people # change this to the domain you want
```

To synthesize AutoQA dataset, with no manual annotation nor human paraphrase, 
run the command with additional options to enable AutoQA and disable human paraphrase 
as follows:
```bash
make datadir experiment=people annotation=auto human_paraphrase=false auto_paraphrase=true
```

If the command failed because misconfiguration or missing library, run `make clean` before you 
rerun `make datadir`.


## Training 
To run training, simply run 
```bash
make train 
```
Similar to `make datadir`, one can append `experiment` option to choose a different domain 
other than `restaurants`.

This automatically trains the BART model proposed in [SKIM](https://arxiv.org/pdf/2009.07968.pdf),
which is currently the state-of-the-art model on Schema2QA benchmark. 
The default setting is under `train_nlu_flags` in the Makefile. One can either tweak
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