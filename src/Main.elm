module Main exposing (..)

import App.Model exposing (..)
import App.ModelHttp exposing (..)
import App.PageType exposing (..)
import App.Router exposing (..)
import App.View exposing (..)
import App.Update exposing (..)
import App.Pages.ContactPage
import Html
import RouteUrl
import RemoteData exposing (RemoteData)
import Dict
import String
import Material


init : Flags -> Model
init flags =
    { flags = flags
    , currentPage = Home
    , pageHome =
        { promotedArticles = RemoteData.NotAsked
        , promotedRecipes = RemoteData.NotAsked
        , recipes = RemoteData.NotAsked
        }
    , pageAboutUs = {}
    , pageRecipes = Dict.empty
    , pageArticles = RemoteData.NotAsked
    , pageRecipeDetail = { recipe = RemoteData.NotAsked, recipes = RemoteData.NotAsked }
    , pageContact = App.Pages.ContactPage.init
    , mdl = Material.model
    }


main =
    RouteUrl.programWithFlags
        { delta2url = delta2url
        , location2messages = location2messages
        , init =
            \flags ->
                init flags
                    |> update (SetActivePage Home)
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
