# encoding: utf-8

#  Copyright (c) 2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module PaymentSlips
  extend ActiveSupport::Concern

  include I18nEnums

  PAYMENT_SLIPS = %w(ch_es ch_bes ch_esr ch_besr).freeze

  included do
    i18n_enum :payment_slip, PAYMENT_SLIPS

    PAYMENT_SLIPS.each do |payment_slip|
      scope payment_slip.to_sym, -> { where(payment_slip: payment_slip) }
      define_method "#{payment_slip}?" do
        self.payment_slip == payment_slip
      end
    end

    def bank?
      ch_bes? || ch_besr?
    end

    def post?
      !bank?
    end

    def with_reference?
      ch_esr? || ch_besr?
    end

    def without_reference?
      !with_reference?
    end
  end
end
