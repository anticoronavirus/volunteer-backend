
CREATE TRIGGER drop_shifts_for_blacklisted AFTER INSERT ON public.blacklist FOR EACH ROW EXECUTE FUNCTION public.drop_shifts_for();