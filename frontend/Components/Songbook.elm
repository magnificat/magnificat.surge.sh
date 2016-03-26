module Components.Songbook where

import Html exposing (Html, div, h1, text, p)
import Html.Attributes exposing (class)
import Effects exposing (Effects)
import Signal
import Effects exposing (Effects)
import Http
import Json.Decode exposing
  ( Decoder, decodeValue, succeed, string, list, int, (:=)
  )
import Json.Decode.Extra exposing ((|:))
import Task

import Components.Dashboard as Dashboard exposing (Category, CategoryId)
import Components.Display as Display exposing (SongBlock)


-- MODEL

type alias Model =
  { title : String
  , subtitle : String
  , categories : Maybe (List Category)
  , songs : Maybe (List Song)
  , dashboard : Dashboard.Model
  , route : Route
  }

type alias Song =
  { number : String
  , title : String
  , category : CategoryId
  , slug : String
  , blocks : List SongBlock
  }

type Route
  = Home
  | DisplaySong SongSlug
  | NotFound

type alias SongSlug =
  String

init :
  { a
  | title : String
  , subtitle : String
  , route : Route
  } -> (Model, Effects Action)
init stub =
  let
    model =
      { title = stub.title
      , subtitle = stub.subtitle
      , categories = Nothing
      , songs = Nothing
      , dashboard = Dashboard.init stub
      , route = stub.route
      }

    effects =
      Effects.batch
        [ getCategories
        , getSongs
        ]

  in
    (model, effects)

toSongData : Song -> Dashboard.SongData
toSongData song =
  { number = song.number
  , title = song.title
  , category = song.category
  }

toSongContent : Song -> Display.SongContent
toSongContent song =
  { blocks = song.blocks
  }


-- UPDATE

type Action
  = Navigate Route
  | RenderCategories (Maybe (List Category))
  | CacheSongs (Maybe (List Song))
  | DashboardAction Dashboard.Action

update : Action -> Model -> (Model, Effects Action)
update action model =
  let
    model = case action of
      Navigate route ->
        { model
        | route = route
        }

      RenderCategories categories ->
        { model
        | categories = categories
        , dashboard = Dashboard.injectCategories categories model.dashboard
        }

      CacheSongs songs ->
        { model
        | songs = songs
        , dashboard = Dashboard.injectSongs
          (Maybe.map (List.map toSongData) songs)
          model.dashboard
        }

      DashboardAction dashboardAction ->
        { model
        | dashboard = Dashboard.update dashboardAction model.dashboard
        }

  in
    (model, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let
    currentSongContent : Maybe Display.SongContent
    currentSongContent =
      Maybe.map toSongContent currentSong

    currentSong : Maybe Song
    currentSong =
      case model.route of
        DisplaySong slug ->
          Maybe.map (List.filter <| \song -> song.slug == slug) model.songs
            `Maybe.andThen` List.head

        _ ->
          Nothing

  in
    div
      [ class "songbook"
      ]
      [ Dashboard.view (Signal.forwardTo address DashboardAction) model.dashboard
      , Display.view <| Display.Model currentSongContent
      ]


-- EFFECTS

getCategories : Effects Action
getCategories =
  Http.get (list category) "/api/categories.json"
    |> Task.toMaybe
    |> Task.map RenderCategories
    |> Effects.task

category : Decoder Category
category =
  succeed Category
    |: ("id" := int)
    |: ("name" := string)

getSongs : Effects Action
getSongs =
  Http.get (list song) "/api/songs.json"
    |> Task.toMaybe
    |> Task.map CacheSongs
    |> Effects.task

song : Decoder Song
song =
  succeed Song
    |: ("number" := string)
    |: ("title" := string)
    |: ("category" := int)
    |: ("slug" := string)
    |: ("blocks" := list songBlock)

songBlock : Decoder SongBlock
songBlock =
  succeed SongBlock
    |: ("type" := string)
    |: ("lyrics" := string)
