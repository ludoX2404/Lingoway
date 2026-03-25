-- Créer la table profiles pour LingoWay
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  target_lang TEXT DEFAULT 'en',
  native_lang TEXT DEFAULT 'fr',
  level TEXT DEFAULT 'A1',
  level_name TEXT DEFAULT 'Débutant',
  score INTEGER DEFAULT 0,
  cert_name TEXT DEFAULT 'TOEFL iBT',
  daily_time INTEGER DEFAULT 30,
  weak_names TEXT[] DEFAULT '{}',
  skill_scores JSONB DEFAULT '{"Grammaire":50,"Vocabulaire":50,"Compréhension":50,"Expression":50,"Lecture":50,"Écriture":50}',
  streak INTEGER DEFAULT 0,
  words_learned INTEGER DEFAULT 0,
  xp_total INTEGER DEFAULT 0,
  motivation INTEGER DEFAULT 0,
  daily_done JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ajouter les colonnes si elles n'existent pas (pour les bases existantes)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS motivation INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS daily_done JSONB DEFAULT '{}';

-- Activer RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux utilisateurs de voir/modifier seulement leur propre profil
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Fonction pour créer automatiquement un profil lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer le profil automatiquement
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();