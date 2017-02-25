module App exposing (..)

import Model
    exposing
        ( Model
        , Shape(..)
        , Tool(..)
        , initialModel
        , RectModel
        , CircleModel
        , SvgPosition
        )
import Msg exposing (Msg(..), ModifyShapeMsg(..))
import Mouse
import Ports


init : () -> ( Model, Cmd Msg )
init flags =
    initialModel ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.downs MouseDown
        , Mouse.ups MouseUp
        , Ports.receiveSvgMouseCoordinates MouseSvgMove
        ]
