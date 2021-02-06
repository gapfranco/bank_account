defmodule BankAccount.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :Offer,
    module: BankAccount.Guardian,
    error_handler: BankAccount.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
