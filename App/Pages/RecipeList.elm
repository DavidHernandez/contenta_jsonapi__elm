module App.Pages.RecipeList exposing (view)

import App.Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (src)
import App.View.Components exposing (viewRecipe)
import RemoteData exposing (WebData, RemoteData(..))


view : Model -> Html Msg
view =
    viewRecipes


viewRemoteData : WebData a -> (a -> Html msg) -> Html msg
viewRemoteData webdata innerView =
    case webdata of
        NotAsked ->
            text "Initialisting"

        Loading ->
            text "Loading"

        Failure err ->
            text ("Error: " ++ toString err)

        Success a ->
            innerView a


viewRecipes : Model -> Html Msg
viewRecipes model =
    viewRemoteData model.recipes
        (\recipes ->
            ul []
                (List.map
                    (\recipe ->
                        (li [] [ viewRecipe recipe ])
                    )
                    recipes
                )
        )
