module Pages.Music.Genre.Genre_String exposing (Params, Model, Msg, page)

import Shared exposing (sendAction, sendActions)
import Colors exposing (greyIcon)
import Components.VerticalNav
import Components.VerticalNavMusic
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route exposing (Route)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Element exposing (..)
import Element.Events
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import WSDecoder exposing (ItemDetails, SongObj, ArtistObj, AlbumObj)
import Helper exposing (durationToString)
import Material.Icons as Filled
import Material.Icons.Types as MITypes exposing (Icon)

page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    { genre : String }


type alias Model =
    { genre : String
    , song_list : List SongObj
    , album_list : List AlbumObj
    , artist_list : List ArtistObj
    , route : Route
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { genre = params.genre
    , song_list = (List.filter (\song -> List.member params.genre song.genre) shared.song_list)
    , album_list = (List.filter (\album -> List.member params.genre album.genre) shared.album_list)
    , artist_list = (List.filter (\artist -> List.member params.genre artist.genre) shared.artist_list)
    , route = Route.Top
    } , Cmd.none )


-- UPDATE


type Msg
    = SetCurrentlyPlaying SongObj


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetCurrentlyPlaying song ->
            ( model
            , sendActions
                [ {- clear the queue -} """{"jsonrpc": "2.0", "id": 0, "method": "Playlist.Clear", "params": {"playlistid": 0}}"""
                , {- add the next song -} """{"jsonrpc": "2.0", "id": 1, "method": "Playlist.Add", "params": {"playlistid": 0, "item": {"songid": """ ++ String.fromInt song.songid ++ """}}}"""
                , {- play -} """{"jsonrpc": "2.0", "id": 0, "method": "Player.Open", "params": {"item": {"playlistid": 0}}}"""
                ]
            )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


materialButton : ( Icon msg, msg ) -> Element msg
materialButton ( icon, action ) =
    Input.button [ paddingXY 5 3 ]
        { onPress = Just action
        , label = Element.html (icon 24 (MITypes.Color <| greyIcon))
        }

-- VIEW


view : Model -> Document Msg
view model =
    { title = "Music.Genre_String"
    , body = [ row [ Element.height fill, Element.width fill ]
                [ Components.VerticalNavMusic.view model.route
                , column [ Element.height fill, Element.width (fillPortion 6), paddingXY 60 0, spacingXY 5 7, Background.color (rgb 0.8 0.8 0.8) ]
                    [ column [Element.height fill, Element.width fill] 
                        [ el [Element.height (fill |> minimum 50 |> maximum 50), Element.width fill, Background.color (rgb 0.9 0.9 0.9)] (Element.text (model.genre ++ " Artists"))
                        , wrappedRow [ Element.height fill, Element.width fill, Background.color (rgb 0.8 0.8 0.8), paddingXY 5 5, spacingXY 5 7 ]
                            (List.map
                                (\artist ->
                                    column [ paddingXY 5 5, Background.color (rgb 1 1 1), mouseOver [ Background.color (rgb 0.9 0.9 0.9) ], Element.height (fill |> minimum 50 |> maximum 50), Element.width (fill |> minimum 150 |> maximum 150), Border.rounded 3 ]
                                        [ el [ Font.center, Font.color (Element.rgb 0 0 0), Font.size 18] (Element.text artist.label)
                                        ]
                                )
                                model.artist_list
                            )
                        ]
                    , column [Element.height fill, Element.width fill] 
                        [ el [Element.height (fill |> minimum 50 |> maximum 50), Element.width fill, Background.color (rgb 0.9 0.9 0.9)] (Element.text (model.genre ++ " Albums"))
                        , wrappedRow [ Element.height fill, Element.width fill, Background.color (rgb 0.8 0.8 0.8), paddingXY 5 5, spacingXY 5 7 ]
                            (List.map
                                (\album ->
                                    column [ paddingXY 5 5, Background.color (rgb 1 1 1), mouseOver [ Background.color (rgb 0.9 0.9 0.9) ], Element.height (fill |> minimum 50 |> maximum 50), Element.width (fill |> minimum 150 |> maximum 150), Border.rounded 3 ]
                                        [ el [ Font.center, Font.color (Element.rgb 0 0 0), Font.size 18] (Element.text album.label)
                                        ]
                                )
                                model.album_list
                            )
                        ]
                    , column [ Element.height fill, Element.width fill, paddingXY 60 0, spacingXY 5 7 ]
                        (List.map
                            (\song ->
                                row [ Element.width fill, paddingXY 5 5, Background.color (rgb 0.2 0.2 0.2), mouseOver [ Background.color (rgb 0.4 0.4 0.4) ], Element.Events.onDoubleClick (SetCurrentlyPlaying song) ]
                                    [ materialButton ( Filled.play_arrow, SetCurrentlyPlaying song )
                                    , materialButton ( Filled.thumb_up, SetCurrentlyPlaying song )
                                    , el [ Font.color (Element.rgb 0.8 0.8 0.8) ] (Element.text song.label)
                                    , row [ alignRight ]
                                        (List.map
                                            (\artist ->
                                                el [ Font.color (Element.rgb 0.8 0.8 0.8), paddingXY 5 0 ] (Element.text artist)
                                            )
                                            song.artist
                                        )
                                    , el [ alignRight, Font.color (Element.rgb 0.8 0.8 0.8) ] (song.duration |> durationToString |> Element.text)
                                    , materialButton ( Filled.more_horiz, SetCurrentlyPlaying song )
                                    ]
                            )
                            model.song_list
                        )
                    ]
                ]
            ]
    }