-- function to set created_at timestamp
create
or replace function set_created_at()
    returns trigger as
$$
begin
    new.created_at
= current_timestamp;
return new;
end;
$$
language plpgsql;

-- function to set updated_at timestamp
create
or replace function set_updated_at()
    returns trigger as
$$
begin
    new.updated_at
= current_timestamp;
return new;
end;
$$
language plpgsql;

-- example of how to use these triggers on a table:
-- create trigger set_timestamp_created
--     before insert on your_table
--     for each row
--     execute function set_created_at();
--
-- create trigger set_timestamp_updated
--     before update on your_table
--     for each row
--     execute function set_updated_at();
