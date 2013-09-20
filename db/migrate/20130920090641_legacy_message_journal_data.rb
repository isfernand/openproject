#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++
#

require_relative 'migration_utils/legacy_journal_migrator'
require_relative 'migration_utils/journal_migrator_concerns'

class LegacyMessageJournalData < ActiveRecord::Migration
  def up
    migrator.run
  end

  def down
    suppress_messages do
      delete <<-SQL
      DELETE
      FROM #{quote_table_name('attachable_journals')}
      WHERE journal_id in (SELECT id
                           FROM #{quote_table_name('legacy_journals')}
                           WHERE type=#{quote_value(migrator.type)})
      SQL

    end

    migrator.remove_journals_derived_from_legacy_journals
  end

  private

  def migrator
    @migrator ||= Migration::LegacyJournalMigrator.new("MessageJournal", "message_journals") do
      extend Migration::JournalMigratorConcerns::Attachable

      def migrate_key_value_pairs!(to_insert, legacy_journal, journal_id)

        migrate_attachments(to_insert, legacy_journal, journal_id)

      end
    end
  end
end
