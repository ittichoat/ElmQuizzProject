port module SimpleQuizz exposing (..)

import Browser
import Html exposing (Html, div, text, label, input, textarea, span, h1, p, a, code, pre)
import Html.Attributes exposing (attribute, class, placeholder, type_, for, rows, style, href, hidden, id)
import Html.Events exposing (onClick, onInput)


import List exposing (..)


type alias QuestionListModel = { questions : List Question, currentQuestion: Int, hiddenQuestion: Bool, version: String}
type alias Question = {  no: Int, title: String, answer: String, mermaid: String, code: String }
type Message = LetPlay | ClickNext | ClickBack | GetFromJS String | SetToJS | ChangeAnswer String

initialModel : QuestionListModel
initialModel = { 
    questions = 
    [ { no = 1, title = "หลังจากรันโค้ดต่อไปนี้ สิ่งใดจะพิมพ์ไปบน console ?", answer = ""
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
        """ }
    , { no = 2, title = "หลังจากรันโค้ดต่อไปนี้ ข้อความใดจะพิมพ์บน console ?", answer = ""
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
        """ }
    , { no = 3, title = "ผลลัพธ์ของ 10 % 5 คืออะไร ?", answer = ""
        , mermaid = """ """
        , code = """
    var result =  10 % 5;
        """ }
    , { no = 4, title = "ค่าของ x คืออะไร ?", answer = ""
        , mermaid = """ """
        , code = """
    let x = 1 + "2";
        """ }
    , { no = 5, title = "คำสั่งใดมีผลทำให้ตัวแปร result เป็นตัวพิมพ์เล็กทั้งหมด ?", answer = ""
        , mermaid = """ """
        , code = """
    let result = 'Hello World';
        """ }
    , { no = 6, title = "คำสั่งที่ใช้สำหรับการขึ้นบรรทัดใหม่ในสตริง?", answer = ""
        , mermaid = """ """
        , code = """ """ }
    , { no = 7, title = "หลังจากรันโค้ดต่อไปนี้ ข้อความใดจะพิมพ์บน console ?", answer = ""
        , mermaid = """ """
        , code = """
    const fruits = ["apple", "banana", "strawberry"];
    fruits
        .map((fruit) => "amazing " + fruit)
        .forEach((fruit) => {
            console.log(fruit);
        })
        """ }
    , { no = 8, title = "หลังจากรันโค้ดต่อไปนี้ ข้อความใดจะพิมพ์บน console ?", answer = ""
        , mermaid = """ """
        , code = """
    const fruits = ["apple", "banana", "strawberry"];
    fruits
        .filter((fruit) => fruit.length > 5)
        .forEach((fruit) => {
            console.log(fruit);
        })
        """ }
    , { no = 9, title = "คำสั่งใด ทำให้สามารถพิมพ์ชื่อและนามสกุลไปที่ console ได้ ?", answer = ""
        , mermaid = """ """
        , code = """
    let person = {
        firstName: "Worawut",
        lastName: "Boonton",
        fullName: function() {
            return this.firstName + " " + this.lastName;
        }
    };
    """ }
    , { no = 10, title = "จงอธิบายการทำงานของโค้ดด้านล่าง", answer = ""
        , mermaid = """ """
        , code = """
    function asyncJob() {
        console.log("Fetching");
        await fetchUserData(); // `fetchUserData` returns an instace of Promise
        console.log("Fetched");
    }
    asyncJob();
        """ }
    , { no = 10, title = "ค่าของ x และ y คืออะไร?", answer = ""
        , mermaid = """ """
        , code = """
    let x,y = 36;
        """ }
    ]
    , currentQuestion = 0
    , hiddenQuestion = True
    , version = "0.0"
  }

init: String -> (QuestionListModel, Cmd Message)
init flags = ({initialModel | version = flags }, toJS initialModel)

initQuestion: Question
initQuestion = { no = 0, title = "FINISH", answer = "", mermaid = "", code="" }

subscriptions : QuestionListModel -> Sub Message
subscriptions model = fromJS GetFromJS
port fromJS : (String -> msg) -> Sub msg
port toJS : QuestionListModel -> Cmd msg
port submitAnswer : String -> Cmd msg

viewQuestion : Question -> Html Message
viewQuestion question =
    div []
        [ div [ class "mb-3" ]
            [ label [ for "address" ]
                [ text (String.fromInt question.no ++ ". " ++ question.title) ]
            , div [ id ("mermaid" ++ String.fromInt question.no) ] []
            , pre [] [ code [ id ("code" ++ String.fromInt question.no), class "language-javascript" ] [] ]
            , textarea  [ class "form-control", placeholder "Please enter answer here", rows 5, onInput ChangeAnswer ]
                [text question.answer]

            ]
        ]

viewNextBackQuestion : QuestionListModel -> Html Message
viewNextBackQuestion model =
    div [ class "row"] 
        [ span [ class "btn btn-warning", onClick ClickBack, style "margin-left" "5px"] [text "Back"]
        , span [ class "btn btn-info", onClick ClickNext, style "margin-left" "5px"] [text "Next"]
        ]

view: QuestionListModel -> Html Message
view model = 
    let 
      currentQuestions = List.filter (\x -> x.no == model.currentQuestion) model.questions
      currentQuestion = case (List.head currentQuestions) of
        Just val -> val
        Nothing -> initQuestion
        
      notShowQuestion = (model.hiddenQuestion || (currentQuestion.title == "FINISH"))
      showFinishBadge = (currentQuestion.title == "FINISH" && not (model.currentQuestion == 0) )
    in
    div []
        [ div [ class "container", hidden (not model.hiddenQuestion) ]
            [ h1 [ class "display-12" ]
                [ text "The exam center for candidate." ]
            , p []
                [ text "“You can’t stop the future. You can’t rewind the past.The only way to learn the secret s to press play.”" ]
            , p []
                [ label [ class "badge badge-secondary"] [ text ("Version:" ++ model.version)]]
            , p []
                [ span [ class "btn btn-primary btn-lg", onClick LetPlay ]
                    [ text "Let's Play »" ]
                ]
            ]
          , div [ class "container", hidden notShowQuestion] [viewQuestion currentQuestion]
          , div [ class "container", hidden notShowQuestion] [viewNextBackQuestion model]
          , div [ class "container", hidden (not showFinishBadge) ]
            [ h1 [ class "display-12" ]
                [ text currentQuestion.title ]
            , p []
                [ text "“You can’t stop the future. You can’t rewind the past.The only way to learn the secret s to press play.”" ]
            , p []
                [   span [ class "btn btn-primary btn-lg" ]
                    [ text "Submit exam answer" ]
                    ,   span [ class "btn btn-warning btn-lg", style "margin-left" "5px", onClick LetPlay ]
                    [ text " Back " ]
                ]
            ]
        ]

update : Message -> QuestionListModel ->(QuestionListModel, Cmd Message)
update msg model =
    case msg of
        ClickNext ->          
          ({ model | currentQuestion = model.currentQuestion + 1 }, toJS { model | currentQuestion = model.currentQuestion + 1 })
        ClickBack ->
          if model.currentQuestion > 1 then
            ({ model | currentQuestion = model.currentQuestion - 1 }, toJS { model | currentQuestion = model.currentQuestion - 1 })
          else
            ({ model | hiddenQuestion = True }, Cmd.none)
        LetPlay ->
          ({ model | currentQuestion = 1, hiddenQuestion = False }, toJS { model | currentQuestion = 1 })
        GetFromJS value ->
          ({ model | version = value }, Cmd.none)
        SetToJS ->
          (model , toJS model)
        ChangeAnswer content ->
          ( model , submitAnswer content)

main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }