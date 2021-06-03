geniedir ?= $(HOME)/genie-toolkit
thingpedia_url = https://almond-dev.stanford.edu/thingpedia
developer_key ?=

-include ./config.mk

memsize := 12000
genie = node --experimental_worker --max_old_space_size=$(memsize) $(geniedir)/dist/tool/genie.js

all_experiments = restaurants hotels people recipes products books movies events music

experiment ?= restaurants
eval_set ?= eval
template_file ?= thingtalk/en/thingtalk.genie
dataset_file ?= emptydataset.tt
synthetic_flags ?= \
	projection_with_filter \
	projection \
	aggregation \
	schema_org \
	filter_join
human_paraphrase ?= true

all_annotation_strategies = baseline auto manual
annotation ?= manual

paraphraser_options ?= --paraphraser-model ./models/paraphraser-bart-large-speedup-megabatch-5m --batch-size 32

baseline_process_schemaorg_flags =
auto_process_schemaorg_flags =
manual_process_schemaorg_flags = --manual

baseline_annotate_flags =
auto_annotate_flags = --algorithms bart-paraphrase $(paraphraser_options)
manual_annotate_flags =

process_schemaorg_flags ?= $($(annotation)_process_schemaorg_flags)
annotate_flags ?= $($(annotation)_annotate_flags)

pruning_size ?= 500
maxdepth ?= 8

restaurants_class_name = org.schema.Restaurant
restaurants_white_list = Restaurant,Review
restaurants_human_paraphrase ?= restaurants/human-paraphrase.tsv

hotels_class_name = org.schema.Hotel
hotels_white_list = Hotel
hotels_human_paraphrase ?= hotels/human-paraphrase.tsv

people_class_name = org.schema.Person
people_white_list = Person
people_human__paraphrase ?= people/human-paraphrase.tsv

books_class_name = org.schema.Book
books_white_list = Book
books_human__paraphrase ?= books/human-paraphrase.tsv

movies_class_name = org.schema.Movie
movies_white_list = Movie
movies_human__paraphrase ?= movies/human-paraphrase.tsv

music_class_name = org.schema.Music
music_white_list = MusicRecording,MusicAlbum
music_human__paraphrase ?= music/human-paraphrase.tsv

generate_flags = $(foreach v,$(synthetic_flags),--set-flag $(v))
evalflags ?=

string_value_sets = \
	tt:job_title \
	tt:location \
	tt:short_free_text \
	tt:long_free_text \
	tt:person_first_name \
	tt:person_full_name \
	tt:song_album \
	tt:song_artist \
	tt:song_name \
	tt:university_names \
	tt:company_name \
	tt:book_name \
	org.openstreetmap:restaurant \
	org.openstreetmap:hotel \
	com.spotify:genre

entity_value_sets = \
	tt:us_state \
	tt:country \
	tt:iso_lang_code

model ?= 1
train_iterations ?= 30000
train_save_every ?= 2000
train_log_every ?= 100
train_nlu_flags ?= \
	--model TransformerSeq2Seq \
	--pretrained_model facebook/bart-large \
	--eval_set_name eval \
	--train_batch_tokens 350 \
	--val_batch_size 400 \
	--preprocess_special_tokens \
	--warmup 800 \
	--lr_multiply 0.01 \
	--override_question= \
	--preserve_case
custom_train_nlu_flags ?=

.PHONY: clean datadir train 
.SECONDARY:

common-words.txt:
	curl -O https://almond-static.stanford.edu/test-data/common-words.txt

models/paraphraser-bart-large-speedup-megabatch-5m:
	mkdir -p models
	curl -O https://almond-static.stanford.edu/test-data/paraphraser-bart-large-speedup-megabatch-5m.tar.xz
	tar -C models -xvf paraphraser-bart-large-speedup-megabatch-5m.tar.xz
	rm paraphraser-bart-large-speedup-megabatch-5m.tar.xz

emptydataset.tt:
	echo 'dataset @empty {}' > $@

source-data: 
	mkdir -p $@
	curl -O https://almond-static.stanford.edu/test-data/schemaorg-source.tar.xz
	tar -C $@ -xvf schemaorg-source.tar.xz
	rm schemaorg-source.tar.xz

shared-parameter-datasets.tsv:
	rm -f $@
	for string_set in $(string_value_sets) ; do \
		$(genie) download-string-values \
		  --manifest $@ \
		  --append-manifest \
		  --thingpedia-url $(thingpedia_url) \
		  --developer-key $(developer_key) \
		  --type $$string_set \
		  -d shared-parameter-datasets ; \
	done
	for entity_set in $(entity_value_sets) ; do \
		$(genie) download-entity-values \
		  --manifest $@ \
		  --append-manifest \
		  --thingpedia-url $(thingpedia_url) \
		  --developer-key $(developer_key) \
		  --type $$entity_set \
	      -d shared-parameter-datasets ; \
	done

$(experiment)/schema.org.tt:
	$(genie) schemaorg-process-schema \
	  -o $@ \
	  --domain $(experiment) \
	  --class-name $($(experiment)_class_name) \
	  --white-list $($(experiment)_white_list) \
	  $(process_schemaorg_flags)

$(experiment)/source-data.json:
	curl https://almond-static.stanford.edu/test-data/schemaorg-source-data/$(experiment).json -o $(experiment)/source-data.json

$(experiment)/data.json : $(experiment)/schema.org.tt $(experiment)/source-data.json
	$(genie) schemaorg-normalize-data \
	  --data-output $@ \
	  --thingpedia $(experiment)/schema.org.tt \
	  --class-name $($(experiment)_class_name) \
	  $(experiment)/source-data.json \
	
$(experiment)/schema.trimmed.tt : $(experiment)/schema.org.tt $(experiment)/data.json
	$(genie) schemaorg-trim-class \
	  -o $@ \
	  --thingpedia $(experiment)/schema.org.tt \
	  --data ./$(experiment)/data.json \
	  --entities $(experiment)/entities.json \
	  --domain $(experiment)

$(experiment)/parameter-datasets.tsv : $(experiment)/schema.trimmed.tt $(experiment)/data.json shared-parameter-datasets.tsv
	$(genie) make-string-datasets \
	  --manifest $@ \
	  -d $(experiment)/parameter-datasets \
	  --thingpedia $(experiment)/schema.trimmed.tt \
	  --data $(experiment)/data.json \
	  --class-name $($(experiment)_class_name) \
	  --dataset schemaorg
	sed 's|\tshared-parameter-datasets|\t../shared-parameter-datasets|g' shared-parameter-datasets.tsv >> $@

$(experiment)/constants.tsv: $(experiment)/parameter-datasets.tsv $(experiment)/schema.trimmed.tt
	$(genie) sample-constants \
	  -o $@ \
	  --parameter-datasets $(experiment)/parameter-datasets.tsv \
	  --thingpedia $(experiment)/schema.trimmed.tt \
	  --devices $($(experiment)_class_name)
	cat $(geniedir)/data/en-US/constants.tsv >> $@

$(experiment)/schema.tt: $(experiment)/constants.tsv $(experiment)/schema.trimmed.tt $(experiment)/parameter-datasets.tsv $(if $(findstring auto,$(annotation)),models/paraphraser-bart-large-speedup-megabatch-5m,) common-words.txt
	$(genie) auto-annotate \
	  -o $@ \
	  --constants $(experiment)/constants.tsv \
	  --thingpedia $(experiment)/schema.trimmed.tt \
	  --functions $($(experiment)_white_list) \
	  --parameter-datasets $(experiment)/parameter-datasets.tsv \
	  --dataset schemaorg \
	  $(annotate_flags)

$(experiment)/synthetic-d%.tsv: $(experiment)/schema.tt $(dataset_file)
	$(genie) generate \
	  -o $@.tmp \
	  --template $(geniedir)/languages-dist/$(template_file) \
	  --thingpedia $(experiment)/schema.tt \
	  --entities $(experiment)/entities.json \
	  --dataset $(dataset_file) \
	  --target-pruning-size $(pruning_size) \
	  --maxdepth $$(echo $* | cut -f1 -d'-') \
	  --random-seed $@ \
	  --debug 3 \
	  $(generate_flags) 
	mv $@.tmp $@

$(experiment)/synthetic.tsv : $(foreach v,1 2 3,$(experiment)/synthetic-d6-$(v).tsv) $(experiment)/synthetic-d$(maxdepth).tsv
	cat $^ > $@

$(experiment)/everything.tsv : $(if $(findstring true,$(human_paraphrase)),$($(experiment)_human_paraphrase),) $(experiment)/synthetic.tsv $(experiment)/parameter-datasets.tsv
	$(genie) augment \
	  -o $@.tmp \
	  -l en-US \
	  --thingpedia $(experiment)/schema.tt \
	  --parameter-datasets $(experiment)/parameter-datasets.tsv \
	  --synthetic-expand-factor 1 \
	  --quoted-paraphrasing-expand-factor 60 \
	  --no-quote-paraphrasing-expand-factor 20 \
	  --quoted-fraction 0.0 \
	  --debug \
	  --no-requotable \
	  $(if $(findstring true,$(human_paraphrase)),$($(experiment)_human_paraphrase),) $(experiment)/synthetic.tsv
	mv $@.tmp $@

datadir: $(experiment)/everything.tsv $(experiment)/eval/annotated.tsv
	mkdir -p $@
	cp $(experiment)/everything.tsv $@/train.tsv
	cut -f1-3 < $(experiment)/eval/annotated.tsv > $@/eval.tsv
	touch $@

train: datadir
	mkdir -p $(experiment)/models/$(model)
	rm -rf datadir/almond
	ln -sf . datadir/almond
	genienlp train \
	  --no_commit \
	  --data datadir \
	  --embeddings .embeddings \
	  --save $(experiment)/models/$(model) \
	  --tensorboard_dir $(experiment)/models/$(model) \
	  --cache datadir/.cache \
	  --train_tasks almond \
	  --preserve_case \
	  --train_iterations $(train_iterations) \
	  --save_every $(train_save_every) \
	  --log_every $(train_log_every) \
	  --val_every $(train_save_every) \
	  --exist_ok \
	  --skip_cache \
	  $(train_nlu_flags) \
	  $(custom_train_nlu_flags)

evaluate: $(experiment)/models/${model}/best.pth $(experiment)/$(eval_set)/annotated.tsv $(experiment)/schema.tt
	$(genie) evaluate-server \
	  --url "file://$(abspath $(experiment)/models/$(model))" \
	  --thingpedia $(experiment)/schema.tt \
	  $(experiment)/$(eval_set)/annotated.tsv \
	  --debug \
	  --csv-prefix \
	  --csv $(evalflags) \
	  --min-complexity 1 \
	  --max-complexity 3 \
	  $(eval_set) -o $@.tmp | tee $(experiment)/$(eval_set)/$*.debug
	mv $@.tmp $@

clean:
	rm -rf datadir
	for exp in $(all_experiments) ; do \
		rm -rf $$exp/synthetic* $$exp/data.json $$exp/entities.json $$exp/parameter-datasets* \
		  $$exp/schema.tt $$exp/manifest.tt $$exp/schema.trimmed.tt $$exp/augmented.tsv \
		  $$exp/constants.tsv ; \
	done