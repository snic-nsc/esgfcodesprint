#!/bin/bash
source /usr/local/conda/bin/activate esgf-pub
esgunpublish --project cordex --map mapfiles/test.map --database-delete --delete
