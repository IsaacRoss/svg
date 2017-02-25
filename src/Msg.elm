module Msg exposing (Msg(..), ModifyShapeMsg(..))

import Model exposing (Shape(..), Tool(..), SvgPosition)
import Mouse
import Drag exposing (DragAction)


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | SelectShape Int
    | AddShape Shape
    | SelectTool Tool
    | MouseSvgMove SvgPosition
    | BeginDrag DragAction
    | EndDrag
    | DeselectShape


type ModifyShapeMsg
    = IncreaseWidth Float
