module Components.Songbook where

import Html exposing (Html, div, h1, text, p, a)
import Html.Attributes exposing (class, href)
import Effects exposing (Effects)
import Signal
import Effects exposing (Effects)
import Http
import Json.Decode exposing
  ( Decoder, decodeValue, succeed, string, list, int, (:=)
  )
import Json.Decode.Extra exposing ((|:))
import Task
import Response

import Components.Dashboard as Dashboard exposing (Category, CategoryId)
import Components.Display as Display exposing (SongBlock)


-- MODEL

type alias Model =
  { categories : Maybe (List Category)
  , songs : Maybe (List Song)
  , dashboard : Dashboard.Model
  , display : Display.Model
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
  | None

type alias SongSlug =
  String

init :
  { title : String
  , subtitle : String
  } -> (Model, Effects Action)
init { title, subtitle } =
  let
    model =
      { categories = Nothing
      , songs = Nothing
      , dashboard = Dashboard.init
        { title = title
        , subtitle = subtitle
        , currentSongSlug = Nothing
        }
      , display = Display.init
      , route = None
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
  , slug = song.slug
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
  | DisplayAction Display.Action
  | FocusDisplay

update : Action -> Model -> (Model, Effects Action)
update action model =
  let
    updateDisplay action =
      let
        (displayModel, displayEffects) =
          Display.update action model.display
      in
        { model
        | display = displayModel
        }
        |> Response.withEffects (Effects.map DisplayAction displayEffects)
  in
    case action of
      Navigate route ->
        let
          dashboardModel =
            model.dashboard

          model' =
            case route of
              DisplaySong slug ->
                { model
                | route = route
                , dashboard = { dashboardModel | currentSongSlug = Just slug }
                }

              _ ->
                { model
                | route = route
                }

        in
          Response.withNone model'

      RenderCategories categories ->
        { model
        | categories = categories
        , dashboard = Dashboard.injectCategories categories model.dashboard
        }
        |> Response.withNone

      CacheSongs songs ->
        { model
        | songs = songs
        , dashboard = Dashboard.injectSongs
          (Maybe.map (List.map toSongData) songs)
          model.dashboard
        }
        |> Response.withNone

      DashboardAction dashboardAction ->
        let
          (dashboardModel, dashboardEffects) =
            Dashboard.update dashboardAction model.dashboard
        in
          { model
          | dashboard = dashboardModel
          }
          |> Response.withEffects (Effects.map DashboardAction dashboardEffects)

      DisplayAction displayAction ->
        updateDisplay displayAction

      FocusDisplay ->
        updateDisplay Display.Focus

appSignal : Signal Action
appSignal =
  Signal.map DashboardAction Dashboard.appSignal


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

    dashboardModel =
      case model.route of
        NotFound ->
          let initialDashboardModel = model.dashboard
          in
            { initialDashboardModel
            | errorMessage = Just
              [ text
                <| "Avast, lone sailor! We can’t find what yerr "
                ++ "lookin’ for. But fear not! Yerr never alone at sea! "
                ++ "You can always sail back to yer "
              , a
                [ href "/"
                ]
                [ text "home port"
                ]
              , text "!"
              ]
            }

        _ ->
          model.dashboard

    displayModel =
      model.display
  in
    case model.route of
      None ->
        text ""

      _ ->
        let
          context =
            { actions = Signal.forwardTo address DashboardAction
            , focusDisplay = Signal.forwardTo address (always FocusDisplay)
            }
        in
          div
            [ class "songbook"
            ]
            [ Dashboard.view context dashboardModel
            , Display.view (Signal.forwardTo address DisplayAction) <|
              { displayModel
              | currentSong = currentSongContent
              }
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
