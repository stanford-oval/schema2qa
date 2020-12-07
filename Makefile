experiment ?= restaurants
eval_set ?= eval
model_name ?= 1
model_path ?=

evaluate: 
	genie
	  --url "file://$(abspath $(dir $(model_path)))" \
	  --thingpedia $(experiment)/schema.tt \
	  $(experiment)/$(eval_set)/annotated.tsv \
	  --debug \
	  --csv \
	  --min-complexity 1 \
	  --max-complexity 3 \
	  -o result.tmp | tee $(experiment)/$(eval_set)/$(model_name).debug
	mv result.tmp $(experiment)/$(eval_set)/$(model_name).results

