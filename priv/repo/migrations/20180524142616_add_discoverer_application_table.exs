defmodule Owaygo.Repo.Migrations.AddDiscovererApplicationTable do
  use Ecto.Migration

  def change do
    create table(:discoverer_application) do
      add :user_id, references(:user)
      add :date, :date, default: fragment("current_date")
      add :reason, :string
      add :status, :string
      timestamps()
    end

    create index(:discoverer_application, :user_id)
  end

  def down do
    drop table(:discoverer_application)
  end
end
