# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "rbs_predicates/predicate_catalog"
require_relative "rbs_predicates/rbs_signature"
require_relative "rbs_predicates/predicate_tests"

namespace :rbs do
  desc "Generate RBS declarations for Event::Key predicates"
  task predicates: :compile do
    Rake::Task["compile"].invoke

    catalog = PredicateCatalog.new
    signature = RbsSignature.new(catalog)
    signature.write
  end

  desc "Generate Minitest assertions for Event::Key predicates"
  task tests: :compile do
    Rake::Task["compile"].invoke

    catalog = PredicateCatalog.new
    tests = PredicateTests.new(catalog)
    tests.persist!
  end
end
