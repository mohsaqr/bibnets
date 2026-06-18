# Aggregate multi-valued fields by an entity

Groups documents by a single-valued or list-column entity (e.g., author,
journal) and pools all values from another list-column (e.g.,
references, keywords) across documents belonging to that entity.

## Usage

``` r
aggregate_by_entity(data, entity_field, value_field, min_freq = 1L)
```

## Arguments

- data:

  A data frame with `id` and the specified columns.

- entity_field:

  Character. Name of the entity column. If it is a scalar column (e.g.,
  `"journal"`), each document belongs to one entity. If it is a
  list-column (e.g., `"authors"`), each document may belong to multiple
  entities.

- value_field:

  Character. Name of the list-column to aggregate (e.g.,
  `"references"`).

- min_freq:

  Integer. Minimum number of papers per entity. Default 1.

## Value

A data frame with columns `id` (entity name) and `value_field`
(list-column of pooled values, with duplicates preserved).
