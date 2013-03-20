#!/bin/sh
 
echo "\n --- delete index"
curl -X DELETE 'http://localhost:9200/test'
 
echo "\n --- create index and put mapping into place"
curl -X POST 'http://localhost:9200/test/' -d '{
    "mappings" : {
        "game" : {
            "properties" : {
                "name": { "type": "string"},
                "edition": {"type": "string"},
                "price": {"type": "string"},
                "difficulty" : {
                    "type" : "nested",
                    "include_in_parent" : false,
                    "properties" : {
                        "action" : {"type" : "string"},
                        "strategy" : {"type" : "boolean"},
                        "game play" : {"type" : "string"}
                    }
                }
            }
        }
    },
    "settings" : {
        "number_of_shards" : 1,
        "number_of_replicas" : 0
    }
}'
 
echo "\n --- index data"
curl -X PUT 'http://localhost:9200/test/game/1' -d '
{
    "name" : "Mario",
    "edition": "one",
    "price": "40",
    "difficulty" : [
        {
            "action" : "4",
            "strategy" : "5",
            "game play" : "2"
        }
    ]
}'
 
curl -X PUT 'http://localhost:9200/test/game/2' -d '
{
    "name" : "Contra",
    "edition": "second",
    "price": "30",
    "difficulty" : [
        {
            "action" : "2",
            "strategy" : "5",
            "game play" : "3"
        }
    ]
}'
 
curl -X PUT 'http://localhost:9200/test/game/3' -d '
{
    "name" : "Snake",
    "edition": "fourth",
    "price": "10",
    "difficulty" : [
        {
            "action" : "3",
            "strategy" : "3",
            "game play" : "3"
        }
        ]
}'
curl -X PUT 'http://localhost:9200/test/game/4' -d '
{
    "name" : "Snake",
    "edition": "fourth",
    "price": "10",
    "difficulty" : [
        {
            "action" : "1",
            "strategy" : "4",
            "game play" : "5"
        }
        ]
}'
 
echo "--- optimize"
curl -X POST 'http://localhost:9200/_optimize'
 
#!/bin/sh
 
echo "--- query 1"
curl -X GET 'http://localhost:9200/test/game/_search?pretty=true' -d '
{
    "query" : {
        "nested" : {
            "path" : "difficulty",
            "query" : {
                "bool" : {
                    "must" : [
                        { "text" : { "difficulty.action" : "2"} }
                    ]
                }
            }
        }
    }
 
}'
 

echo "--- query 2"
curl -X GET 'http://localhost:9200/test/game/_search?pretty=true' -d '
{
    "query" : {
        "nested" : {
            "path" : "difficulty",
            "query" : {
                "bool" : {
                    "must" : [
                        { "text" : { "difficulty.game play" : "3"} }
                    ]
                }
            }
        }
    }
 
}'


echo "--- query 3"
curl -X GET 'http://localhost:9200/test/game/_search?pretty=true' -d '
{
    "query" : {
        "nested" : {
            "path" : "difficulty",
            "query" : {
                "bool" : {
                    "must" : [
                        { "text" : { "difficulty.game play" : "3"} }
                        { "text" : { "difficulty.action" : "3"} }
                    ]
                }
            }
        }
    }
 
}'

echo "--- query 4"
curl -X GET 'http://localhost:9200/test/game/_search?q=difficulty_level.game%20play=3&pretty'


echo "--- query 5"
curl -X GET 'http://localhost:9200/test/game/_search?q=difficulty_level.action=4&pretty'


echo "--- query 6"
curl -X GET 'http://localhost:9200/test/game/_search?q=difficulty_level.strategy=3&pretty'


echo "\n --- done"

