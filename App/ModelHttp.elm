module App.ModelHttp exposing (..)

import App.Model exposing (..)
import Json.Encode
import Json.Decode exposing (..)
import JsonApi
import JsonApi.Http
import Http


recipeDecoderWithIdAndImage : String -> Maybe String -> Decoder Recipe
recipeDecoderWithIdAndImage id image =
    map8 Recipe
        (succeed id)
        (field "title" string)
        (field "field_difficulty" string)
        (field "field_ingredients" (list string))
        (field "field_total_time" int)
        (field "field_preparation_time" int)
        (field "field_recipe_instruction" (field "value" string))
        (succeed image)


articleDecoderWithIdAndImage : String -> Maybe String -> Decoder Article
articleDecoderWithIdAndImage id image =
    map4 Article
        (succeed id)
        (field "title" string)
        (at [ "body", "value" ] string)
        (succeed image)


getRecipes : Cmd Msg
getRecipes =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                ("http://localhost:8890/node/recipe?include=field_image&fields[file--file]=uuid,url,uri&fields[node--recipe]="
                    ++ "title,"
                    ++ "field_difficulty,"
                    ++ "field_ingredients,"
                    ++ "field_total_time,"
                    ++ "field_preparation_time,"
                    ++ "field_recipe_instruction,"
                    ++ "field_image"
                )
    in
        Http.send RecipesLoaded request


getArticles : Cmd Msg
getArticles =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                ("http://localhost:8890/node/article?include=field_image&fields[file--file]=uuid,url,uri&fields[node--article]="
                    ++ "title,"
                    --                    ++ "field_image,"
                    ++
                        "field_recipes,"
                    ++ "body"
                )
    in
        Http.send ArticlesLoaded request


getPromotedRecipes : Cmd Msg
getPromotedRecipes =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                ("http://localhost:8890/node/recipe?include=field_image&fields[file--file]=uuid,url,uri&fields[node--recipe]="
                    ++ "title,"
                    ++ "field_difficulty,"
                    ++ "field_ingredients,"
                    ++ "field_total_time,"
                    ++ "field_preparation_time,"
                    ++ "field_recipe_instruction,"
                    ++ "field_image"
                    ++ "&filter[promote][value]=1"
                    ++ "&pager[limit]=3"
                )
    in
        Http.send PromotedRecipesLoaded request


getPromotedArticles : Cmd Msg
getPromotedArticles =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                ("http://localhost:8890/node/article?include=field_image&fields[file--file]=uuid,url,uri&fields[node--article]="
                    ++ "title,"
                    ++ "field_image,"
                    ++ "field_recipes,"
                    ++ "body,"
                    ++ "&filter[promote][value]=1"
                    ++ "&pager[limit]=3"
                )
    in
        Http.send PromotedArticlesLoaded request


getRecipe : String -> Cmd Msg
getRecipe id =
    let
        request =
            JsonApi.Http.getPrimaryResource
                ("http://localhost:8890/node/recipe/"
                    ++ id
                    ++ "?include=field_image&fields[file--file]=uuid,url,uri&fields[node--recipe]="
                    ++ "title,"
                    ++ "field_difficulty,"
                    ++ "field_ingredients,"
                    ++ "field_total_time,"
                    ++ "field_preparation_time,"
                    ++ "field_recipe_instruction,"
                    ++ "field_image"
                )
    in
        Http.send RecipeLoaded request


fileDecoder : Decoder File
fileDecoder =
    map2 File
        (field "uuid" string)
        (field "url" string)



--loginRequest : LoginDetails -> Cmd Msg
--loginRequest loginDetails =
--    let
--        request =
--            123
--    in
--        Http.send (Result Http.Error LoginCompleted)
--            (Http.post "http://localhost:8890/user/login?_format=json"
--                (encodeLoginData loginDetails)
--                decodeLoginResult
--            )
--
--
--encodeLoginData : LoginDetails -> Http.Body
--encodeLoginData details =
--    Http.jsonBody <|
--        Json.Encode.object
--            [ ("name" Json.Encode.string details.name)
--            , ("pass" Json.Encode.string details.password)
--            ]
--
--decodeLoginResult : Json.Decoder
