module App.Model exposing (..)

import App.PageType exposing (..)
import Http
import JsonApi


type Msg
    = RecipeLoaded (Result Http.Error JsonApi.Resource)
    | RecipesLoaded (Result Http.Error (List JsonApi.Resource))
    | GetRecipe String
    | GetRecipes
    | SetActivePage Page
    | SelectRecipe String
    | LoginFormState Bool
    | InputLoginName String
    | InputLoginPassword String
    | InputLoginSubmit
      -- | LoginCompleted
    | PromotedRecipesLoaded (Result Http.Error (List JsonApi.Resource))
    | PromotedArticlesLoaded (Result Http.Error (List JsonApi.Resource))


type alias Recipe =
    { id : String
    , title : String
    , difficulty : String
    , ingredients : List String
    , totalTime : Int
    , prepTime : Int
    , recipeInstruction : String
    , image : Maybe String
    }


type ArticleOrRecipe
    = ArticleId String
    | RecipeId String


type alias Article =
    { id : String
    , title : String
    , body : String
    , image : Maybe String
    }


type alias File =
    { uuid : String
    , url : String
    }


type alias LoginDetails =
    { name : String
    , password : String
    }


type alias Model =
    { recipes : Maybe (List Recipe)
    , selectedRecipe : Maybe String
    , currentPage : Page
    , loginFormActive : Bool
    , loginDetails : Maybe LoginDetails
    , pages :
        { home :
            { promotedArticles : Maybe (List Article)
            , promotedRecipes : Maybe (List Recipe)
            }
        }
    }
