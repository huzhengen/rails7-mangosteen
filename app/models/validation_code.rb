class ValidationCode < ApplicationRecord
  has_secure_token :code, length: 24
end
