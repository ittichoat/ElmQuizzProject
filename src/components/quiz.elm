port module SimpleQuizz exposing (..)

import Browser
import Html exposing (Html, a, code, div, form, h1, input, label, p, pre, span, text, textarea)
import Html.Attributes exposing (attribute, class, for, hidden, href, id, placeholder, rows, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, at, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import List exposing (..)
import Random


type alias QuestionListModel =
    { questions : List Question, questionNumber : Int, hiddenQuestion : Bool, candidateID : String }


type alias Question =
    { no : Int, title : String, answer : String, mermaid : String, code : String, markdown : String }


type Msg
    = LetPlay
    | ClickNext Question
    | ClickBack Question
    | GetFromJS String
    | InputAnswer String
    | SubmitAnswer
    | SetToJS
    | GetQuestions (Result Http.Error (List Question))


type Status
    = Loading
    | Loaded (List Question) String
    | Errored String


initQuestion : Question
initQuestion =
    { no = 0, title = "FINISH", answer = "", mermaid = "", code = "", markdown = "" }


initialCmd : Cmd Msg
initialCmd =
    Http.get
        { url = "http://localhost:4000/api/v1/users"
        , expect = Http.expectJson GetQuestions (list questionDecoder)
        }


questionDecoder : Decoder Question
questionDecoder =
    succeed Question
        |> required "no" int
        |> optional "title" string "(untitled)"
        |> optional "answer" string "(untitled)"
        |> optional "mermaid" string "(untitled)"
        |> optional "code" string "(untitled)"
        |> optional "markdown" string "(untitled)"


initialModel : QuestionListModel
initialModel =
    { questions =
        [ { no = 1
          , title = "หลังจากรันโค้ดต่อไปนี้ สิ่งใดจะพิมพ์ไปบน console ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    var x = 5;
    const foo = {
        x: 100,
        getX() {
            return this.x;
        }
    };
    const bar = {
        x: 20
    };
    bar.getX = foo.getX;
    console.log(bar.getX());
        """
          , markdown = """ """
          }
        , { no = 2
          , title = "หลังจากรันโค้ดต่อไปนี้ ข้อความใดจะพิมพ์บน console ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    const basket = {
        apple: 2,
        banana: 4,
        orange: 6,
        strawberry: 8
    }
    for (const fruit in basket) {
        console.log(fruit);
    }
        """
          , markdown = """ """
          }
        , { no = 3
          , title = "ผลลัพธ์ของ 10 % 5 คืออะไร ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    var result =  10 % 5;
        """
          , markdown = """ """
          }
        , { no = 4
          , title = "ค่าของ x คืออะไร ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    let x = 1 + "2";
        """
          , markdown = """ """
          }
        , { no = 5
          , title = "คำสั่งใดมีผลทำให้ตัวแปร result เป็นตัวพิมพ์เล็กทั้งหมด ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    let result = 'Hello World';
        """
          , markdown = """ """
          }
        , { no = 6
          , title = "คำสั่งที่ใช้สำหรับการขึ้นบรรทัดใหม่ในสตริง?"
          , answer = ""
          , mermaid = """ """
          , code = """ """
          , markdown = """ """
          }
        , { no = 7
          , title = "หลังจากรันโค้ดต่อไปนี้ ข้อความใดจะพิมพ์บน console ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    const fruits = ["apple", "banana", "strawberry"];
    fruits
        .map((fruit) => "amazing " + fruit)
        .forEach((fruit) => {
            console.log(fruit);
        })
        """
          , markdown = """ """
          }
        , { no = 8
          , title = "หลังจากรันโค้ดต่อไปนี้ ข้อความใดจะพิมพ์บน console ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    const fruits = ["apple", "banana", "strawberry"];
    fruits
        .filter((fruit) => fruit.length > 5)
        .forEach((fruit) => {
            console.log(fruit);
        })
        """
          , markdown = """ """
          }
        , { no = 9
          , title = "คำสั่งใด ทำให้สามารถพิมพ์ชื่อและนามสกุลไปที่ console ได้ ?"
          , answer = ""
          , mermaid = """ """
          , code = """
    let person = {
        firstName: "Worawut",
        lastName: "Boonton",
        fullName: function() {
            return this.firstName + " " + this.lastName;
        }
    };
        """
          , markdown = """ """
          }
        , { no = 10
          , title = "จงอธิบายการทำงานของโค้ดด้านล่าง"
          , answer = ""
          , mermaid = """ """
          , code = """
    function asyncJob() {
        console.log("Fetching");
        await fetchUserData(); // `fetchUserData` returns an instace of Promise
        console.log("Fetched");
    }
    asyncJob();
        """
          , markdown = """ """
          }
        , { no = 11
          , title = "ค่าของ x และ y คืออะไร?"
          , answer = ""
          , mermaid = """ """
          , code = """
    let x,y = 36;
        """
          , markdown = """ """
          }
        ]
    , questionNumber = 0
    , hiddenQuestion = True
    , candidateID = ""
    }


init : String -> ( QuestionListModel, Cmd Msg )
init flags =
    ( initialModel, Cmd.batch [ code_heighlight initialModel, initialCmd ] )


subscriptions : QuestionListModel -> Sub Msg
subscriptions model =
    from_js GetFromJS


port from_js : (String -> message) -> Sub message


port code_heighlight : QuestionListModel -> Cmd message


port change_answer : QuestionListModel -> Cmd message


port submit_answer : QuestionListModel -> Cmd message


viewStartBadge : QuestionListModel -> Html Msg
viewStartBadge model =
    div []
        [ h1 [ class "display-12" ]
            [ text "The exam center for candidate." ]
        , p []
            [ text "“You can’t stop the future. You can’t rewind the past.The only way to learn the secret s to press play.”" ]
        , p []
            [ label [ class "badge badge-secondary" ] [ text "Candidate ID : ", input [ style "padding-left" "5px", type_ "text", value model.candidateID, placeholder "Enter your ID here." ] [] ] ]
        , p []
            [ span [ class "btn btn-primary btn-lg", onClick LetPlay ]
                [ text "Let's Play »" ]
            ]
        ]


viewFinishBadge : Question -> Bool -> Html Msg
viewFinishBadge question showFinishBadge =
    div [ class "container", hidden (not showFinishBadge) ]
        [ h1 [ class "display-12" ]
            [ text question.title ]
        , p []
            [ text "“You can’t stop the future. You can’t rewind the past.The only way to learn the secret s to press play.”" ]
        , p []
            [ span [ class "btn btn-primary btn-lg", type_ "button", onClick SubmitAnswer ]
                [ text "Submit exam answer" ]
            , span [ class "btn btn-warning btn-lg", type_ "button", style "margin-left" "5px", onClick LetPlay ]
                [ text " Back " ]
            ]
        ]


viewDownloadLink : Html Msg
viewDownloadLink =
    div []
        [ p [ class "text-bold-load" ] [ text "Download Programmer" ]
        , p []
            [ text "Exam JS TDD:"
            , a [ href "https://github.com/iTopPlus/ExamJSTDD" ] [ text "Exam JS TDD" ]
            ]
        , p [ class "text-bold-load" ] [ text "Download" ]
        , p []
            [ text "ClosePackage Lab:"
            , a [ href "/assets/exam/ClosePackage_Q2.xlsx" ] [ text "Excel Test Exam I(Close Job)" ]
            ]
        , p []
            [ text "Test Website Lab:"
            , a [ href "/assets/exam/Test_Website.xlsx" ] [ text "Excel Test Exam II (Test_Website Job)" ]
            ]
        ]


viewQuestion : Question -> Bool -> Html Msg
viewQuestion question notShowQuestion =
    div []
        [ div [ class "mb-3" ]
            [ label [ for "address" ]
                [ text (String.fromInt question.no ++ ". " ++ question.title) ]
            , div [ id ("mermaid" ++ String.fromInt question.no) ] []
            , div [ id ("markdown" ++ String.fromInt question.no) ] []
            , pre [] [ code [ id ("code" ++ String.fromInt question.no), class "language-javascript" ] [] ]
            , input [ type_ "text", class "form-control", placeholder "Please enter answer here", rows 5, onInput InputAnswer, value question.answer ] []
            ]
        , div [ class "container", hidden notShowQuestion ] [ viewNextBack question ]
        ]


viewNextBack : Question -> Html Msg
viewNextBack question =
    div [ class "row" ]
        [ input [ class "btn btn-warning", onClick (ClickBack question), style "margin-left" "5px", type_ "submit", value "Back" ] []
        , input [ class "btn btn-info", onClick (ClickNext question), style "margin-left" "5px", type_ "submit", value "Next" ] []
        ]


view : QuestionListModel -> Html Msg
view model =
    let
        currentQuestions =
            List.filter (\x -> x.no == model.questionNumber) model.questions

        currentQuestion =
            case List.head currentQuestions of
                Just val ->
                    val

                Nothing ->
                    initQuestion

        notShowQuestion =
            model.hiddenQuestion || (currentQuestion.title == "FINISH")

        showFinishBadge =
            currentQuestion.title == "FINISH" && not (model.questionNumber == 0)
    in
    div []
        [ div [ class "container", hidden (not model.hiddenQuestion) ]
            [ viewStartBadge model
            , viewDownloadLink
            ]
        , div [ class "container", hidden notShowQuestion ] [ viewQuestion currentQuestion notShowQuestion ]
        , viewFinishBadge currentQuestion showFinishBadge
        ]


update : Msg -> QuestionListModel -> ( QuestionListModel, Cmd Msg )
update message model =
    case message of
        ClickNext currentQuestion ->
            let
                currentModel =
                    { model | questionNumber = model.questionNumber + 1 }
            in
            ( currentModel, code_heighlight currentModel )

        ClickBack currentQuestion ->
            let
                currentModel =
                    { model | questionNumber = model.questionNumber - 1 }

                resultModel =
                    if model.questionNumber > 1 then
                        ( currentModel, code_heighlight currentModel )

                    else
                        ( { currentModel | hiddenQuestion = True }, Cmd.none )
            in
            resultModel

        LetPlay ->
            let
                currentModel =
                    { model | questionNumber = 1, hiddenQuestion = False }

                resultModel =
                    ( currentModel, code_heighlight currentModel )
            in
            resultModel

        InputAnswer answer ->
            let
                currentModel =
                    updateAnswer answer model
            in
            ( currentModel, change_answer currentModel )

        SubmitAnswer ->
            ( model, submit_answer model )

        GetFromJS value ->
            ( { model | candidateID = value }, Cmd.none )

        SetToJS ->
            ( model, code_heighlight model )

        GetQuestions (Ok questions) ->
            case questions of
                first :: rest ->
                    ( model, Cmd.none )

                [] ->
                    ( model, Cmd.none )

        GetQuestions (Err httpError) ->
            ( model, Cmd.none )


updateAnswer : String -> QuestionListModel -> QuestionListModel
updateAnswer answer model =
    let
        toggle index question =
            if index == model.questionNumber - 1 then
                { question | answer = answer }

            else
                question
    in
    { model | questions = List.indexedMap toggle model.questions }


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
