class CreateRequest
  include Interactor

  delegate :bucket, :rack_request, to: :context

  def call
    context.request = bucket.requests.create(
      body:           rack_request.body.read.force_encoding(Encoding::UTF_8),
      content_length: rack_request.content_length,
      request_method: rack_request.request_method,
      ip:             rack_request.ip,
      url:            rack_request.url,
      headers:        FilterHeaders.call(headers: rack_request.env).headers
    )

    context.params = rack_request.request_parameters
  rescue
    Rollbar.scope!(request: context.request)
    raise
  end
end
