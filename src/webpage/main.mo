import Types "types";
import Result "mo:base/Result";
import Text "mo:base/Text";

import daoCanister "canister:dao";

actor class Webpage(daoPrincipal : Principal) = this {

    type Result<A, B> = Result.Result<A, B>;
    type HttpRequest = Types.HttpRequest;
    type HttpResponse = Types.HttpResponse;

    stable var manifesto : Text = "from Webpage - Implement government Budget through DAO";
    // stable var manifesto : Text = await getManifesto();
    stable var goals : [Text] = [];
    // stable var logo : Text = "";

    stable var name : Text = "";


    stable var logo : Text = "<?xml version='1.0' encoding='UTF-8'?>
<svg xmlns='http://www.w3.org/2000/svg' id='Layer_1' data-name='Layer 1' viewBox='0 0 24 24'>
  <path d='m3.5,20c1.103,0,2-.897,2-2s-.897-2-2-2-2,.897-2,2,.897,2,2,2Zm0-3c.551,0,1,.448,1,1s-.449,1-1,1-1-.448-1-1,.449-1,1-1Zm6.5,1c0,1.103.897,2,2,2s2-.897,2-2-.897-2-2-2-2,.897-2,2Zm3,0c0,.552-.449,1-1,1s-1-.448-1-1,.449-1,1-1,1,.448,1,1Zm-1-14c1.103,0,2-.897,2-2s-.897-2-2-2-2,.897-2,2,.897,2,2,2Zm0-3c.551,0,1,.448,1,1s-.449,1-1,1-1-.448-1-1,.449-1,1-1Zm6.5,17c0,1.103.897,2,2,2s2-.897,2-2-.897-2-2-2-2,.897-2,2Zm3,0c0,.552-.449,1-1,1s-1-.448-1-1,.449-1,1-1,1,.448,1,1ZM4,14h-1v-2c0-1.103.897-2,2-2h14c1.103,0,2,.897,2,2v2h-1v-2c0-.552-.449-1-1-1h-6.5v3h-1v-3h-6.5c-.551,0-1,.448-1,1v2Zm3,9v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1H0v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2Zm17,0v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1h-1v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2Zm-8.5,0v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1h-1v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2Zm-6-15h-1v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1Z'/>
</svg>";


    func _getWebpage() : Text {

        var webpage = "<style>" #
        "body { text-align: center; font-family: Arial, sans-serif; background-color: #f0f8ff; color: #333; }" #
        "h1 { font-size: 3em; margin-bottom: 10px; }" #
        "hr { margin-top: 20px; margin-bottom: 20px; }" #
        "em { font-style: italic; display: block; margin-bottom: 20px; }" #
        "ul { list-style-type: none; padding: 0; }" #
        "li { margin: 10px 0; }" #
        "li:before { content: '👉 '; }" #
        "svg { max-width: 150px; height: auto; display: block; margin: 20px auto; }" #
        "h2 { text-decoration: underline; }" #
        "</style>";

        webpage := webpage # "<div><h1>" # name # "</h1></div>";
        webpage := webpage # "<em>" # manifesto # "</em>";
        webpage := webpage # "<div>" # logo # "</div>";
        webpage := webpage # "<hr>";
        webpage := webpage # "<h2>Our goals:</h2>";
        webpage := webpage # "<ul>";
        for (goal in goals.vals()) {
            webpage := webpage # "<li>" # goal # "</li>";
        };
        webpage := webpage # "</ul>";
        return webpage;
    };


    public query func http_request(request : HttpRequest) : async HttpResponse {
        // Asynchronously fetch the manifesto from the other canister
        // let manifestoText = await daoCanister.getManifesto();
        // Now pass the fetched manifestoText to _getWebpage
        // let webpageContent = _getWebpage(manifestoText);
        return ({
            // status_code = 404;
            status_code = 200 : Nat16;  // 200 means everything is correct
            // headers = [];
            headers = [("Content-Type", "text/html; charset=UTF-8")];  // return HTML page
            // body = Text.encodeUtf8("Hello world!");
            
            body = Text.encodeUtf8(_getWebpage());
            streaming_strategy = null;
        });
    };


    public func getManifesto() : async Text {
            let manifesto = await daoCanister.getManifesto();
            return manifesto;
    };

    public shared ({ caller }) func setManifesto(newManifesto : Text) : async Result<(), Text> {
        manifesto := newManifesto;
        return #err("Not implemented");
    };

    // public func getManifesto() : async Text {
    //     return "Not implemented";
    // };

    public shared ({ caller }) func addGoal(goal : Text) : async Result<(), Text> {
        return #err("Not implemented");
    };

    public func getGoals() : async [Text] {
        return [];
    };
};
