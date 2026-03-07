import AuthenticationServices

class AppleAuthManager {

    static func createRequest() -> ASAuthorizationAppleIDRequest {

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()

        request.requestedScopes = [.fullName, .email]

        return request
    }

}