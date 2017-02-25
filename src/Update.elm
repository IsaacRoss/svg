module Update exposing (update)

import Model
    exposing
        ( Model
        , Shape(..)
        , Tool(..)
        , RectModel
        , CircleModel
        , SvgPosition
        )
import Msg exposing (Msg(..))
import Drag exposing (DragAction(..))
import Dict exposing (Dict)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ mouse } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MouseMove pos ->
            let
                nextMouse =
                    { mouse | position = pos }
            in
                { model | mouse = nextMouse } ! []

        MouseDown pos ->
            let
                nextMouse =
                    { mouse | down = True, downSvgPosition = mouse.svgPosition }
            in
                { model | mouse = nextMouse } ! []

        MouseUp pos ->
            let
                nextMouse =
                    { mouse | down = False }
            in
                { model
                    | mouse = nextMouse
                    , dragAction = Nothing
                    , comparedShape = Nothing
                }
                    ! []

        MouseSvgMove pos ->
            let
                nextMouse =
                    { mouse | svgPosition = pos }

                nextModel =
                    handleDrag pos model
            in
                { nextModel | mouse = nextMouse } ! []

        SelectShape shapeId ->
            { model
                | selectedShapeId = Just shapeId
            }
                ! []

        AddShape shape ->
            ( model |> addShape shape
            , Cmd.none
            )

        SelectTool tool ->
            { model | selectedTool = tool } ! []

        BeginDrag dragAction ->
            let
                comparedShape =
                    case model.selectedShapeId of
                        Nothing ->
                            Nothing

                        Just shapeId ->
                            Dict.get shapeId model.shapes

                nextMouse =
                    { mouse | downSvgPosition = mouse.svgPosition }
            in
                { model
                    | dragAction = Just dragAction
                    , comparedShape = comparedShape
                    , mouse = nextMouse
                }
                    ! []

        EndDrag ->
            { model
                | dragAction = Nothing
                , comparedShape = Nothing
            }
                ! []

        DeselectShape ->
            { model
                | selectedShapeId = Nothing
            }
                ! []


handleDrag : SvgPosition -> Model -> Model
handleDrag pos model =
    case model.dragAction of
        Nothing ->
            model

        Just dragAction ->
            case model.selectedShapeId of
                Nothing ->
                    model

                Just shapeId ->
                    case model.comparedShape of
                        Nothing ->
                            model

                        Just shape ->
                            handleDragAction dragAction shapeId shape pos model


handleDragAction : DragAction -> Int -> Shape -> SvgPosition -> Model -> Model
handleDragAction dragAction shapeId shape pos ({ mouse } as model) =
    let
        newShape : Shape
        newShape =
            case dragAction of
                DragMove ->
                    let
                        dragDiffX =
                            mouse.downSvgPosition.x - mouse.svgPosition.x

                        dragDiffY =
                            mouse.downSvgPosition.y - mouse.svgPosition.y
                    in
                        case shape of
                            Rect rectModel ->
                                Rect
                                    { rectModel
                                        | x = rectModel.x - dragDiffX
                                        , y = rectModel.y - dragDiffY
                                    }

                            Circle circleModel ->
                                Circle
                                    { circleModel
                                        | cx = circleModel.cx - dragDiffX
                                        , cy = circleModel.cy - dragDiffY
                                    }

                DragResize ->
                    case ( shape, model.comparedShape ) of
                        ( Circle circleModel, Just (Circle compCircle) ) ->
                            let
                                newRX =
                                    abs (pos.x - circleModel.cx)

                                newRY =
                                    abs (pos.y - circleModel.cy)

                                newR =
                                    max newRX newRY
                            in
                                Circle
                                    { circleModel
                                        | r = newR
                                    }

                        ( Rect rectModel, Just (Rect compRect) ) ->
                            let
                                ( newX, newWidth ) =
                                    if pos.x <= compRect.x then
                                        ( pos.x, compRect.x - pos.x )
                                    else
                                        ( compRect.x, pos.x - compRect.x )

                                ( newY, newHeight ) =
                                    if pos.y <= compRect.y then
                                        ( pos.y, compRect.y - pos.y )
                                    else
                                        ( compRect.y, pos.y - compRect.y )
                            in
                                Rect
                                    { rectModel
                                        | width = newWidth
                                        , height = newHeight
                                        , x = newX
                                        , y = newY
                                    }

                        _ ->
                            shape
    in
        { model
            | shapes =
                Dict.insert shapeId
                    newShape
                    model.shapes
        }


addShape : Shape -> Model -> Model
addShape shape model =
    let
        shapes : Dict Int Shape
        shapes =
            model.shapes

        maxId : Int
        maxId =
            shapes
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 0

        nextShapes : Dict Int Shape
        nextShapes =
            model.shapes
                |> Dict.insert (maxId + 1) shape
    in
        { model | shapes = nextShapes }
