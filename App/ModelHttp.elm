module App.ModelHttp exposing (..)

import App.Model exposing (..)
import Json.Encode
import Json.Decode exposing (..)
import JsonApi.Resources
import JsonApi
import JsonApi.Http
import Http
import RemoteData
import Result.Extra
import Json.Decode.Extra


recipeDecoderWithValues : String -> Maybe String -> List Term -> Decoder Recipe
recipeDecoderWithValues id image tags =
    map8 Recipe
        (succeed id)
        (field "title" string)
        (field "field_difficulty" string)
        (field "field_ingredients" (list string))
        (field "field_total_time" int)
        (field "field_preparation_time" int)
        (field "field_recipe_instruction" (field "value" string))
        (succeed image)
        |> Json.Decode.Extra.andMap (succeed tags)


articleDecoderWithIdAndImage : String -> Maybe String -> Decoder Article
articleDecoderWithIdAndImage id image =
    map4 Article
        (succeed id)
        (field "title" string)
        (at [ "body", "value" ] string)
        (succeed image)


getArticles : Flags -> Cmd Msg
getArticles flags =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                (flags.apiBaseUrl
                    ++ "/node/article"
                    ++ "?"
                    ++ "include=field_image,field_image.field_image,field_image.field_image.file--file,field_tags"
                    ++ "&fields[field_image]=field_image&fields[file--file]=url,uuid"
                    ++ "title,"
                    ++ "field_recipes,"
                    ++ "body,"
                    ++ "field_tags,"
                )
    in
        RemoteData.sendRequest request
            |> Cmd.map ArticlesLoaded


getRecipePerCategory : Flags -> String -> Cmd Msg
getRecipePerCategory flags category =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                (flags.apiBaseUrl
                    ++ "/node/recipe"
                    ++ "?"
                    ++ "include=field_image,field_image.field_image,field_image.field_image.file--file,field_tags"
                    ++ "&fields[field_image]=field_image&fields[file--file]=url,uuid"
                    ++ "&fields[node--recipe]="
                    ++ "title,"
                    ++ "field_difficulty,"
                    ++ "field_ingredients,"
                    ++ "field_total_time,"
                    ++ "field_preparation_time,"
                    ++ "field_recipe_instruction,"
                    ++ "field_image,"
                    ++ "field_tags,"
                    ++ "&fields[taxonomy_term--tags]=tid,name"
                    ++ "&pager[limit]=4"
                    ++ "&filter[field_category.name][value]="
                    ++ category
                )
    in
        RemoteData.sendRequest request
            |> Cmd.map (RecipesPerCategoryLoaded category)


getPromotedRecipes : Flags -> Cmd Msg
getPromotedRecipes flags =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                (flags.apiBaseUrl
                    ++ "/node/recipe"
                    ++ "?"
                    ++ "include=field_image,field_image.field_image,field_image.field_image.file--file,field_tags"
                    ++ "&fields[field_image]=field_image&fields[file--file]=url,uuid"
                    ++ "&fields[node--recipe]="
                    ++ "title,"
                    ++ "field_difficulty,"
                    ++ "field_ingredients,"
                    ++ "field_total_time,"
                    ++ "field_preparation_time,"
                    ++ "field_recipe_instruction,"
                    ++ "field_image,"
                    ++ "field_tags,"
                    ++ "&fields[taxonomy_term--tags]=tid,name"
                    ++ "&filter[promote][value]=1"
                    ++ "&pager[limit]=3"
                )
    in
        RemoteData.sendRequest request
            |> Cmd.map PromotedRecipesLoaded


getPromotedArticles : Flags -> Cmd Msg
getPromotedArticles flags =
    let
        request =
            JsonApi.Http.getPrimaryResourceCollection
                (flags.apiBaseUrl
                    ++ "/node/article"
                    ++ "?"
                    ++ "include=field_image,field_image.field_image,field_image.field_image.file--file,field_tags"
                    ++ "&fields[field_image]=field_image&fields[file--file]=url,uuid"
                    ++ "&fields[node--article]="
                    ++ "title,"
                    ++ "field_image,"
                    ++ "field_tags,"
                    ++ "field_recipes,"
                    ++ "body,"
                    ++ "&fields[taxonomy_term--tags]=tid,name"
                    ++ "&filter[promote][value]=1"
                    ++ "&pager[limit]=3"
                )
    in
        RemoteData.sendRequest request
            |> Cmd.map PromotedArticlesLoaded


getRecipe : Flags -> String -> Cmd Msg
getRecipe flags id =
    let
        request =
            JsonApi.Http.getPrimaryResource
                (flags.apiBaseUrl
                    ++ "/node/recipe/"
                    ++ id
                    ++ "?"
                    ++ "include=field_image,field_image.field_image,field_image.field_image.file--file,field_tags"
                    ++ "&fields[field_image]=field_image&fields[file--file]=url,uuid"
                    ++ "&fields[node--recipe]="
                    ++ "title,"
                    ++ "field_difficulty,"
                    ++ "field_ingredients,"
                    ++ "field_total_time,"
                    ++ "field_preparation_time,"
                    ++ "field_recipe_instruction,"
                    ++ "field_image,"
                    ++ "field_tags,"
                    ++ "&fields[taxonomy_term--tags]=tid,name"
                )
    in
        RemoteData.sendRequest request
            |> Cmd.map RecipeLoaded


fileDecoder : Decoder File
fileDecoder =
    map2 File
        (field "uuid" string)
        (field "url" string)


termDecoder : Decoder Term
termDecoder =
    map2 Term
        (field "tid" int)
        (field "name" string)


mediaDecoder : Decoder Media
mediaDecoder =
    map Media
        (field "uuid" string)


decodeRecipe : Flags -> JsonApi.Resource -> Maybe Recipe
decodeRecipe flags resource =
    let
        id =
            JsonApi.Resources.id resource

        file_image =
            JsonApi.Resources.relatedResource "field_image" resource
                |> Result.andThen (JsonApi.Resources.relatedResource "field_image")
                |> Result.andThen (JsonApi.Resources.attributes fileDecoder)
                |> Result.map (\file -> { file | url = flags.baseUrl ++ file.url })
                |> Result.toMaybe

        tags =
            JsonApi.Resources.relatedResourceCollection "field_tags" resource
                |> Result.andThen
                    (\resources ->
                        (List.map (JsonApi.Resources.attributes termDecoder) resources
                            |> Result.Extra.combine
                        )
                    )
                |> Result.withDefault []

        recipeResult =
            JsonApi.Resources.attributes (recipeDecoderWithValues id (Maybe.map .url file_image) tags) resource
                |> Result.toMaybe
    in
        recipeResult


decodeArticle : Flags -> JsonApi.Resource -> Maybe Article
decodeArticle flags resource =
    let
        id =
            JsonApi.Resources.id resource

        file_image =
            JsonApi.Resources.relatedResource "field_image" resource
                |> Result.andThen (JsonApi.Resources.relatedResource "field_image")
                |> Result.andThen (JsonApi.Resources.attributes fileDecoder)
                |> Result.map (\file -> { file | url = flags.baseUrl ++ file.url })
                |> Result.toMaybe

        articleResult =
            JsonApi.Resources.attributes (articleDecoderWithIdAndImage id (Maybe.map .url file_image)) resource
                |> Result.toMaybe
    in
        articleResult
