import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Option "mo:base/Option";

actor ArtGallery {
  public type ArtId = Nat;
  
  public type Art = {
    title: Text;
    description: Text;
    artist: Text;
    likes: Nat;
    comment: Text;
  };
  
  stable var next : ArtId = 0;
  let Ops = Map.Make<ArtId>(Nat.compare);
  stable var map : Map.Map<ArtId, Art> = Ops.empty();
  
  public func uploadArtwork(title: Text, description: Text, artist: Text): async ArtId {
    let artId = next;
    next += 1;
    
    let art : Art = {
      title = title;
      description = description;
      artist = artist;
      likes = 0;
      comment = "default";
    };
    
    map := Ops.put(map, artId, art);
    return artId;
  };
  
  public query func getArtwork(artId : ArtId) : async ?Art {
    return Ops.get(map, artId);
  };
  
  // public query func getAllArtworks() : async [(ArtId, Art)] {
  //   return Ops.entries(map);
  // };
  
  public func likeArtwork(artId : ArtId) : async Bool {
    let artOpt = Ops.get(map, artId);
    switch (artOpt) {
      case (?art) {
        let updatedArt = {
          title = art.title;
          description = art.description;
          artist = art.artist;
          likes = art.likes + 1;
          comment = "default";
        };
        map := Ops.put(map, artId, updatedArt);
        return true;
      };
      case null {
        return false;
      }
    }
  };
  
  public func addComment(artId : ArtId, comment : Text) : async Bool {
    let artOpt = Ops.get(map, artId);
    switch (artOpt) {
      case (?art) {
        let updatedArt = {
          title = art.title;
          description = art.description;
          artist = art.artist;
          likes = art.likes;
          comment = comment;
        };
        map := Ops.put(map, artId, updatedArt);
        return true;
      };
      case null {
        return false;
      }
    }
  };
  
  public func deleteArtwork(artId : ArtId) : async Bool {
    let (result, old_value) = Ops.remove(map, artId);
    let exists = Option.isSome(old_value);
    if (exists) {
      map := result;
    };
    return exists;
  };
}
