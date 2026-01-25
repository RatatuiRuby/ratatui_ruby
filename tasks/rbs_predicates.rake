# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# NOTE: Do NOT require predicate_catalog here - it requires ratatui_ruby,
# which needs the native extension to be compiled first. Require inside tasks.

namespace :rbs do
  desc "Generate RBS declarations for Event::Key predicates"
  task predicates: :compile do
    require_relative "rbs_predicates/predicate_catalog"
    require_relative "rbs_predicates/rbs_signature"

    catalog = PredicateCatalog.new
    signature = RbsSignature.new(catalog)
    signature.write
  end

  desc "Generate Minitest assertions for Event::Key predicates"
  task tests: :compile do
    require_relative "rbs_predicates/predicate_catalog"
    require_relative "rbs_predicates/predicate_tests"

    catalog = PredicateCatalog.new
    tests = PredicateTests.new(catalog)
    tests.persist!
  end
end
