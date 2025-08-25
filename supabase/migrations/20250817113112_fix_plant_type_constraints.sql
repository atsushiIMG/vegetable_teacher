ALTER TABLE user_vegetables
DROP CONSTRAINT user_vegetables_plant_type_check,
ADD CONSTRAINT user_vegetables_plant_type_check
CHECK (plant_type IN ('seed', 'seedling'));