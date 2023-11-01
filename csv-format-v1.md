# Nettskjema CSV Format V1

## CSV-Specifics

| feature                     | value   |
|-----------------------------|---------|
| delimiter                   | `;`     |
| double quote                | `true`  |
| quote character             | `"`     |
| line separator              | `\r\n`  |
| whitespace before separator | `false` |
| whitespace after separator  | `false` |

The last row containing data in the CSV file should end with `\r\n`.

### Example

```csv
"$submission_id";"$created";"var1";"$answer_time"
"28508117";"2023-08-29T10:52:11.828301592+02:00";"abc 123";"6473"
```

### Example with double-qouting

Double-quoting means that any element containing quote-characters have the characters replaced
by two quote character. In this example, the user has entered `this is a "quote"`
in the element with codebook value `var1`:

```csv
"$submission_id";"$created";"var1";"$answer_time"
"28508117";"2023-08-29T10:52:11.828301592+02:00";"this is a ""quote""";"6473"
```

## Ordering

The rows are ordered by `$submission_id` in ascending order.

## Header naming

### Hardcoded header names

| header               | description                                      |
|----------------------|--------------------------------------------------|
| `$submission_id`     | Unique identifier for each answer                |
| `$created`           | Date and time this submission was submitted      |
| `$forwarded_to_form` | Which form the participant has been forwarded to |
| `$signed`            | Status for delivery of signature                 |
| `$answer_time_ms`    | Time spent by participant to complete the survey |

### Headers from survey elements

#### Simple elements

The following elements, will produce a header which is simply the codebook value
for the element:

* QUESTION
* QUESTION_MULTILINE
* RADIO
* SELECT
* DATE
* NATIONAL_ID_NUMBER
* EMAIL
* PHONE
* SUBMISSION_REFERENCE
* USERNAME
* LINEAR_SCALE
* NUMBER
* ATTACHMENT
* NAME

#### Complex elements

##### CHECKBOX Headers

For checkbox, the codebook contains a codebook value for the element as well,
referred to as `ELEMENT`. There are also codebook values for each answer option,
referred to as `ANSWER_OPTION`.

For each answer option, the header will be constructed as following:

`ELEMENT.ANSWER_OPTION`

##### MATRIX_RADIO Headers

For radio matricies, the codebook contains the a value for the matrix itself, `MATRIX_ID`.
Each row get a value `ROW_ID`, and each column a `COL_ID`.

For each row in the matrix, the header will be constructed as following:

`MATRIX_ID.ROW_ID`

##### MATRIX_CHECKBOX Headers

For checkbox matricies, the codebook contains the a value for the matrix itself, `MATRIX_ID`.
Each row get a value `ROW_ID`, and each column a `COL_ID`.

For each row in the matrix, the header will be constructed as following:

`MATRIX_ID.ROW_ID.COL_ID`

### Header ordering

The headers appear in the following order:

1. `$submission_id`
2. `$created`
3. `$forwarded_to_form` if the form forwards to other forms, omitted if not.
4. `$signed` if the document requires digital signing, omitted if not.
5. Elements of the survey, in the order they appear in the survey itself.
6. `$answer_time_ms`

### Element values

#### $submission_id

Contains the submission id.

#### $created

Contains the date of the submission in ISO 8601 format with timezone. If the form is not set to
collect personal data, the timestamp is rounded last midnight.

Example: `"2023-10-17T13:33:48.666743778+02:00"`

#### $forwarded_to_form

Contains the FORM_ID of the form the user was forwarded to.

#### $signed

Contains a 1 if the signature has been delivered, and 0 not delivered.

#### $answer_time_ms

Contains the time the participant took to answer the survey, in milliseconds.

#### QUESTION

Appear as they do in the survey itself. If the answer contains multiple lines, lineshift will be
replaced by a space.

#### QUESTION_MULTILINE

Appear as the do in the survey itself. If the answer contains multiple lines, lineshifts will be
replaced by a space.

#### RADIO

Contains the codebook value of the chosen option.

#### SELECT

Contains the codebook value of the chosen option.

#### DATE

Contains the chosen date in ISO 8601 format. Empty if no date is chosen.

Example:
`"2023-06-01T11:11"`

#### NATIONAL_ID_NUMBER

Contains the national id number

Example:
`"22028711111"`

#### EMAIL

Contains the email address.

Example:
`"user.lastname@emailservice.com"`

#### PHONE

Contains the entered phone number.

Example:
`"99887755"`

#### SUBMISSION_REFERENCE

Contains the submission reference.

Example:
`"368964"`

#### USERNAME

Contains the username.

Example:
`"username"`

#### LINEAR_SCALE

Contains the chosen number.
Example:
`"10"`

#### NUMBER

Contains the entered number.

Example:
`"10"`

#### ATTACHMENT

The filename is constructed using the `SUBMISSION_ID`, `FORM_ID` and the `ORIGINAL_FILENAME`
of the uploaded file, in the following way.

`FORM_ID-SUBMISSION_ID-ORIGINAL_FILENAME`

Example:
`"368964-27830787-filname.txt"`

#### NAME

Contains the name of the participant. Might be capitalized.

Example:
`"FIRSTNAME LASTNAME"`

#### MATRIX_RADIO

The codebook value of the selected element per row will be the value.

Example (with headers):

```text
"matrix_r.row1";"matrix_r.row2"
"col1";"col1"
"col1";"col2"
```

#### CHECKBOX

The elements that have been checked will have a value of 1.

If the element has been hidden from the participant, the value will be empty.

Example (with headers):

```text
"var1.1";"var1.2";"var1.3"
"0";"1";"0"
"1";"1";"1"
"";"";""
```

#### MATRIX_CHECKBOX

The elements that have been checked will have a value of 1.

If the element has been hidden from the participant, the value will be empty.

Example (with headers):

```text
"matrix_c.row1.col1";"matrix_c.row1.col2";"matrix_c.row2.col1";"matrix_c.row2.col2"
"0";"0";"0";"0"
"1";"0";"1";"0"
"";"";"";""
```
