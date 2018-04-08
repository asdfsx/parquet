-module(parquet_reader).
-compile(export_all).
-include_lib("kernel/include/file.hrl").
-include("thrift/gen-erl/parquet_types.hrl").

-define(ParquetMagic, <<"PAR1">>).

main() ->
    Filename = "/Users/sunxia/git_project/parquet/test/000007_0",
    {ok, Facts} = file:read_file_info(Filename),
    io:format("1~p~n", [Facts#file_info.size]),
    FileLength = Facts#file_info.size,
    case file:open(Filename, [read, binary, raw]) of
        {ok, S} ->
            {ok, Header} = readHeader(S),
            io:format("1 Header ~p~n", [Header == ?ParquetMagic]),
            {ok, Footer} = readFooter(S, FileLength),
            io:format("2 Footer ~p~n", [Footer == ?ParquetMagic]),
            {ok, <<MetaLen:32/integer-signed-little>>} = readRawMetaLen(S, FileLength),
            io:format("3 MetaLen ~p~n", [MetaLen]),
            {ok, RawMeta} = readRawMeta(S, FileLength, MetaLen),
            
            %%% 读取文件meta
            {ok, Result} = parseFileMeta(RawMeta),
            io:format("4 version ~p~n", [Result]),
            io:format("4 version ~p~n", [Result#'FileMetaData'.'version']),
            io:format("5 schema ~p~n", [Result#'FileMetaData'.'schema']),
            [FirstGroup|_] = Result#'FileMetaData'.'row_groups',
            [FirstColumnChunk|_] = FirstGroup#'RowGroup'.'columns',
            io:format("6 FirstColumnChunk ~p~n", [FirstColumnChunk]),
            io:format("6 FirstColumnMeta type ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.'type']),
            io:format("6 FirstColumnMeta encodings ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.encodings]),
            io:format("6 FirstColumnMeta path_in_schema ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.path_in_schema]),
            io:format("6 FirstColumnMeta codec ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.codec]),
            io:format("6 FirstColumnMeta num_values ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.num_values]),
            io:format("6 FirstColumnMeta total_uncompressed_size ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.total_uncompressed_size]),
            io:format("6 FirstColumnMeta total_compressed_size ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.total_compressed_size]),
            io:format("6 FirstColumnMeta data_page_offset ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.data_page_offset]),
            io:format("6 FirstColumnMeta index_page_offset ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.index_page_offset]),
            io:format("6 FirstColumnMeta encoding_stats ~p~n", [FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.encoding_stats]),

            %%% column chunk 信息
            Begin = FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.data_page_offset,
            Len = FirstColumnChunk#'ColumnChunk'.'meta_data'#'ColumnMetaData'.total_compressed_size,

            %%% 根据 column chunk 读取 column data
            {ok, ColumnData} = readColumnData(S, Begin, Len),
            io:format("~p~n", [ColumnData]),

            %%% 从 column data 中获取 page header
            {ok, PageHeader} = parsePageHeader(ColumnData),
            io:format("pageheader type ~p~n", [PageHeader#'PageHeader'.type]),
            io:format("pageheader compressed_page_size ~p~n", [PageHeader#'PageHeader'.compressed_page_size]),
            io:format("pageheader data_page_header ~p~n", [PageHeader#'PageHeader'.data_page_header]),
            io:format("pageheader index_page_header ~p~n", [PageHeader#'PageHeader'.index_page_header]),
            io:format("pageheader DictionaryPageHeader ~p~n", [PageHeader#'PageHeader'.dictionary_page_header]),
            io:format("pageheader data_page_header_v2 ~p~n", [PageHeader#'PageHeader'.data_page_header_v2]),
            
            %%% 根据 column meta 读取 第一个 page


            file:close(S);
        {error, Why} ->
            io:format("File open error:~p~n", [Why])
    end.

readHeader(S) ->
    file:pread(S, 0, 4).

readFooter(S, FileLength) ->
    file:pread(S, FileLength-4, 4).

readRawMetaLen(S, FileLength) ->
    file:pread(S, FileLength-8, 4).

readRawMeta(S, FileLength, Metalen) ->
    file:pread(S, FileLength-Metalen-8, Metalen+8).

readColumnData(S, Begin, Len) ->
    file:pread(S, Begin, Len).

parseFileMeta(RawData) ->
    case thrift_membuffer_transport:new(RawData) of
        {ok, Transport} ->
            case thrift_compact_protocol:new(Transport) of
                {ok, CompactProtocol} ->
                    {_CompactProtocol, Result} = thrift_protocol:read(CompactProtocol, {struct, {parquet_types,'FileMetaData'}}),
                    Result;
                _ ->
                    {fail, "failed to create thrift_compact_protocol"}
            end;
        _ ->
            {fail, "failed to create thrift_membuffer_transport"}
    end.

parsePageHeader(RawData) ->
    case thrift_membuffer_transport:new(RawData) of
        {ok, Transport} ->
            case thrift_compact_protocol:new(Transport) of
                {ok, CompactProtocol} ->
                    {_CompactProtocol, Result} = thrift_protocol:read(CompactProtocol, {struct, {parquet_types,'PageHeader'}}),
                    Result;
                _ ->
                    {fail, "failed to create thrift_compact_protocol"}
            end;
        _ ->
            {fail, "failed to create thrift_membuffer_transport"}
    end.

