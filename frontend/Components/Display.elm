module Components.Display where

import Html exposing (Html, div, text, p, br)
import Html.Attributes exposing (class, classList, property)
import Html.Events exposing (onClick)
import String
import Time exposing (Time)
import Effects exposing (Effects)
import Easing
import Json.Encode


-- MODEL

type alias Model =
  { currentSong : Maybe SongContent
  , mode : Mode
  , animationState : AnimationState
  }

type alias SongContent =
  { blocks : List SongBlock
  }

type alias SongBlock =
  { blockType : String
  , lyrics : String
  }

type Mode
  = ShiftedAway
  | InFocus

type alias AnimationState =
  Maybe
    { previousClockTime : Time
    , elapsedTime : Time
    }

dashboardWidth :
  { width : Int
  , rootFontSize : Int
  }
dashboardWidth =
  { width = 400
  , rootFontSize = 16
  }
  -- TODO: This should come from elm-styles.

duration : Time
duration =
  300 * Time.millisecond

init : Model
init =
  { currentSong = Nothing
  , mode = ShiftedAway
  , animationState = Nothing
  }


-- UPDATE

type Action
  = ShiftAway
  | Focus
  | Tick TargetMode Time

type alias TargetMode =
  Mode

update : Action -> Model -> (Model, Effects Action)
update action model =
  case (action, model.animationState, model.mode) of
    (ShiftAway, Nothing, InFocus) ->
      ( model
      , Effects.tick <| Tick ShiftedAway
      )

    (Focus, Nothing, ShiftedAway) ->
      ( model
      , Effects.tick <| Tick InFocus
      )

    (Tick targetMode clockTime, _, _) ->
      let
        newElapsedTime =
          case model.animationState of
            Nothing ->
              0

            Just { previousClockTime, elapsedTime } ->
              elapsedTime + (clockTime - previousClockTime)
      in
        if newElapsedTime > duration
          then
            ( { model
              | mode = targetMode
              , animationState = Nothing
              }
            , Effects.none
            )

          else
            ( { model
              | animationState = Just
                { previousClockTime = clockTime
                , elapsedTime = newElapsedTime
                }
              }
            , Effects.tick <| Tick targetMode
            )

    _ ->
      (model, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let
    displayContents =
      case model.currentSong of
        Nothing ->
          []

        Just song ->
          List.map renderSongBlock song.blocks

    renderSongBlock block =
      let
        lines = String.split "\n" block.lyrics
      in p
        [ classList
          [ ("display’s-song-block", True)
          , ("display’s-song-block·type»refrain", block.blockType == "refrain")
          ]
        ]
        <| List.map renderLine lines

    renderLine line =
      div [class "display’s-song-line"] [text line]

    leftScrollOffset =
      let
        focusMargin =
          dashboardWidth.width

        shiftedAwayMargin =
          0
      in
        case (model.mode, model.animationState) of
          (InFocus, Nothing) ->
            focusMargin

          (ShiftedAway, Nothing) ->
            shiftedAwayMargin

          (_, Just animationState) ->
            let
              (from, to) = case model.mode of
                InFocus ->
                  (focusMargin, shiftedAwayMargin)

                ShiftedAway ->
                  (shiftedAwayMargin, focusMargin)
            in
              round <| Easing.ease
                Easing.easeOutExpo
                Easing.float
                (toFloat from)
                (toFloat to)
                duration
                animationState.elapsedTime
  in
    div
      [ class "display’s-wrapper"
      , property
          "scrollLeft"
          <| Json.Encode.int leftScrollOffset
      ]
      [ div
        [ class "display"
        , onClick address ShiftAway
        ]
        displayContents
      ]
