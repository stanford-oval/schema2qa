# Statistics of Schema2QA 2.0 dataset
#### Schema2QA Training:
|                            | restaurants | people  | movies  | books   | music   | hotels  | average |
| -------------------------- | ----------- | ------- | ------- | ------- | ------- | ------- | ------- |
| Synthetic                  | 165,634     | 165,634 | 165,634 | 165,634 | 165,634 | 165,634 | 165,634 |
| Human Paraphrase           | 6,419       | 7,108   | 3,774   | 3,941   | 3,626   | 3,311   | 4,697   |
| Total (after augmentation) | 477,934     | 541,034 | 292,434 | 305,694 | 322,554 | 302,414 | 373,677 |

#### AutoQA Training 
|                            | restaurants | people  | movies  | books   | music   | hotels  | average |
| -------------------------- | ----------- | ------- | ------- | ------- | ------- | ------- | ------- |
| Synthetic                  | 165,634     | 165,634 | 165,634 | 165,634 | 165,634 | 165,634 | 165,634 |
| Auto Paraphrase (filtered) | 205,867     | 163,467 | 164,342 | 188,259 | 202,870 | 220,428 | 190,872 |
| Total                      | 371,501     | 329,101 | 329,976 | 353,893 | 368,504 | 386,062 | 356,506 |

#### Evaluation: 
|            | restaurants | people | movies | books | music | hotels | average |
| ---------- | ----------- | ------ | ------ | ----- | ----- | ------ | ------- |
| Validation | 528         | 499    | 380    | 360   | 312   | 443    | 420.3   |
| Test       | 524         | 500    | 404    | 407   | 286   | 528    | 441.5   |