-ifndef(_parquet_types_included).
-define(_parquet_types_included, yeah).

-define(PARQUET_TYPE_BOOLEAN, 0).
-define(PARQUET_TYPE_INT32, 1).
-define(PARQUET_TYPE_INT64, 2).
-define(PARQUET_TYPE_INT96, 3).
-define(PARQUET_TYPE_FLOAT, 4).
-define(PARQUET_TYPE_DOUBLE, 5).
-define(PARQUET_TYPE_BYTE_ARRAY, 6).
-define(PARQUET_TYPE_FIXED_LEN_BYTE_ARRAY, 7).

-define(PARQUET_CONVERTEDTYPE_UTF8, 0).
-define(PARQUET_CONVERTEDTYPE_MAP, 1).
-define(PARQUET_CONVERTEDTYPE_MAP_KEY_VALUE, 2).
-define(PARQUET_CONVERTEDTYPE_LIST, 3).
-define(PARQUET_CONVERTEDTYPE_ENUM, 4).
-define(PARQUET_CONVERTEDTYPE_DECIMAL, 5).
-define(PARQUET_CONVERTEDTYPE_DATE, 6).
-define(PARQUET_CONVERTEDTYPE_TIME_MILLIS, 7).
-define(PARQUET_CONVERTEDTYPE_TIME_MICROS, 8).
-define(PARQUET_CONVERTEDTYPE_TIMESTAMP_MILLIS, 9).
-define(PARQUET_CONVERTEDTYPE_TIMESTAMP_MICROS, 10).
-define(PARQUET_CONVERTEDTYPE_UINT_8, 11).
-define(PARQUET_CONVERTEDTYPE_UINT_16, 12).
-define(PARQUET_CONVERTEDTYPE_UINT_32, 13).
-define(PARQUET_CONVERTEDTYPE_UINT_64, 14).
-define(PARQUET_CONVERTEDTYPE_INT_8, 15).
-define(PARQUET_CONVERTEDTYPE_INT_16, 16).
-define(PARQUET_CONVERTEDTYPE_INT_32, 17).
-define(PARQUET_CONVERTEDTYPE_INT_64, 18).
-define(PARQUET_CONVERTEDTYPE_JSON, 19).
-define(PARQUET_CONVERTEDTYPE_BSON, 20).
-define(PARQUET_CONVERTEDTYPE_INTERVAL, 21).

-define(PARQUET_FIELDREPETITIONTYPE_REQUIRED, 0).
-define(PARQUET_FIELDREPETITIONTYPE_OPTIONAL, 1).
-define(PARQUET_FIELDREPETITIONTYPE_REPEATED, 2).

-define(PARQUET_ENCODING_PLAIN, 0).
-define(PARQUET_ENCODING_PLAIN_DICTIONARY, 2).
-define(PARQUET_ENCODING_RLE, 3).
-define(PARQUET_ENCODING_BIT_PACKED, 4).
-define(PARQUET_ENCODING_DELTA_BINARY_PACKED, 5).
-define(PARQUET_ENCODING_DELTA_LENGTH_BYTE_ARRAY, 6).
-define(PARQUET_ENCODING_DELTA_BYTE_ARRAY, 7).
-define(PARQUET_ENCODING_RLE_DICTIONARY, 8).

-define(PARQUET_COMPRESSIONCODEC_UNCOMPRESSED, 0).
-define(PARQUET_COMPRESSIONCODEC_SNAPPY, 1).
-define(PARQUET_COMPRESSIONCODEC_GZIP, 2).
-define(PARQUET_COMPRESSIONCODEC_LZO, 3).

-define(PARQUET_PAGETYPE_DATA_PAGE, 0).
-define(PARQUET_PAGETYPE_INDEX_PAGE, 1).
-define(PARQUET_PAGETYPE_DICTIONARY_PAGE, 2).
-define(PARQUET_PAGETYPE_DATA_PAGE_V2, 3).

%% struct 'Statistics'

-record('Statistics', {'max' :: string() | binary(),
                       'min' :: string() | binary(),
                       'null_count' :: integer(),
                       'distinct_count' :: integer()}).
-type 'Statistics'() :: #'Statistics'{}.

%% struct 'SchemaElement'

-record('SchemaElement', {'type' :: integer(),
                          'type_length' :: integer(),
                          'repetition_type' :: integer(),
                          'name' :: string() | binary(),
                          'num_children' :: integer(),
                          'converted_type' :: integer(),
                          'scale' :: integer(),
                          'precision' :: integer(),
                          'field_id' :: integer()}).
-type 'SchemaElement'() :: #'SchemaElement'{}.

%% struct 'DataPageHeader'

-record('DataPageHeader', {'num_values' :: integer(),
                           'encoding' :: integer(),
                           'definition_level_encoding' :: integer(),
                           'repetition_level_encoding' :: integer(),
                           'statistics' :: 'Statistics'()}).
-type 'DataPageHeader'() :: #'DataPageHeader'{}.

%% struct 'IndexPageHeader'

-record('IndexPageHeader', {}).
-type 'IndexPageHeader'() :: #'IndexPageHeader'{}.

%% struct 'DictionaryPageHeader'

-record('DictionaryPageHeader', {'num_values' :: integer(),
                                 'encoding' :: integer(),
                                 'is_sorted' :: boolean()}).
-type 'DictionaryPageHeader'() :: #'DictionaryPageHeader'{}.

%% struct 'DataPageHeaderV2'

-record('DataPageHeaderV2', {'num_values' :: integer(),
                             'num_nulls' :: integer(),
                             'num_rows' :: integer(),
                             'encoding' :: integer(),
                             'definition_levels_byte_length' :: integer(),
                             'repetition_levels_byte_length' :: integer(),
                             'is_compressed' = true :: boolean(),
                             'statistics' :: 'Statistics'()}).
-type 'DataPageHeaderV2'() :: #'DataPageHeaderV2'{}.

%% struct 'PageHeader'

-record('PageHeader', {'type' :: integer(),
                       'uncompressed_page_size' :: integer(),
                       'compressed_page_size' :: integer(),
                       'crc' :: integer(),
                       'data_page_header' :: 'DataPageHeader'(),
                       'index_page_header' :: 'IndexPageHeader'(),
                       'dictionary_page_header' :: 'DictionaryPageHeader'(),
                       'data_page_header_v2' :: 'DataPageHeaderV2'()}).
-type 'PageHeader'() :: #'PageHeader'{}.

%% struct 'KeyValue'

-record('KeyValue', {'key' :: string() | binary(),
                     'value' :: string() | binary()}).
-type 'KeyValue'() :: #'KeyValue'{}.

%% struct 'SortingColumn'

-record('SortingColumn', {'column_idx' :: integer(),
                          'descending' :: boolean(),
                          'nulls_first' :: boolean()}).
-type 'SortingColumn'() :: #'SortingColumn'{}.

%% struct 'PageEncodingStats'

-record('PageEncodingStats', {'page_type' :: integer(),
                              'encoding' :: integer(),
                              'count' :: integer()}).
-type 'PageEncodingStats'() :: #'PageEncodingStats'{}.

%% struct 'ColumnMetaData'

-record('ColumnMetaData', {'type' :: integer(),
                           'encodings' = [] :: list(),
                           'path_in_schema' = [] :: list(),
                           'codec' :: integer(),
                           'num_values' :: integer(),
                           'total_uncompressed_size' :: integer(),
                           'total_compressed_size' :: integer(),
                           'key_value_metadata' :: list(),
                           'data_page_offset' :: integer(),
                           'index_page_offset' :: integer(),
                           'dictionary_page_offset' :: integer(),
                           'statistics' :: 'Statistics'(),
                           'encoding_stats' :: list()}).
-type 'ColumnMetaData'() :: #'ColumnMetaData'{}.

%% struct 'ColumnChunk'

-record('ColumnChunk', {'file_path' :: string() | binary(),
                        'file_offset' :: integer(),
                        'meta_data' :: 'ColumnMetaData'()}).
-type 'ColumnChunk'() :: #'ColumnChunk'{}.

%% struct 'RowGroup'

-record('RowGroup', {'columns' = [] :: list(),
                     'total_byte_size' :: integer(),
                     'num_rows' :: integer(),
                     'sorting_columns' :: list()}).
-type 'RowGroup'() :: #'RowGroup'{}.

%% struct 'FileMetaData'

-record('FileMetaData', {'version' :: integer(),
                         'schema' = [] :: list(),
                         'num_rows' :: integer(),
                         'row_groups' = [] :: list(),
                         'key_value_metadata' :: list(),
                         'created_by' :: string() | binary()}).
-type 'FileMetaData'() :: #'FileMetaData'{}.

-endif.
