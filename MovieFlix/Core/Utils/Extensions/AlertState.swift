import ComposableArchitecture

extension AlertState where Action == MovieListFeature.Action {
    static func error(_ message: String, dismiss: Action) -> AlertState {
           AlertState(
               title: TextState("Error"),
               message: TextState(message),
               dismissButton: .default(
                   TextState("OK"),
                   action: .send(dismiss)
               )
           )
       }
}
