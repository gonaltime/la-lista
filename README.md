# La Lista 🛒

Lista de la compra compartida para la familia. Web app que se añade a la pantalla de inicio; los datos se guardan en Supabase.

Web: https://gonaltime.github.io/la-lista/

## Conectarla a una cuenta de Supabase (5 minutos)

1. **Crea el proyecto.** En supabase.com → *New project*. Ponle de nombre `La Lista`, elige una región de Europa (por ejemplo París) y una contraseña cualquiera. Espera a que termine de crearse.
2. **Crea la base de datos.** En el proyecto, ve a *SQL Editor* → *New query*, pega todo el contenido de [`schema.sql`](schema.sql) y pulsa *Run*. Debe decir "Success".
3. **Copia la dirección y la clave.** Ve a *Project Settings* → *API Keys* (o el botón *Connect* de arriba) y copia:
   - la **Project URL** (algo como `https://xxxxxxxx.supabase.co`)
   - la **Publishable key** (empieza por `sb_publishable_…`). Esta clave es pública, está bien que vaya en la web. **Nunca** uses la *secret key*.
4. **Pégalas en la app.** En este repo, abre `index.html` (botón del lápiz para editar) y cambia estas dos líneas, al principio del `<script>` de abajo:
   ```js
   const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   const SUPABASE_KEY = "sb_publishable_…";
   ```
   Pulsa *Commit changes*. En uno o dos minutos la web estará actualizada.
5. **Empieza la lista.** Abre la web en el móvil (si ya la tenías, ciérrala y ábrela de nuevo), pulsa *Crear la lista de mi familia* y comparte el enlace con *Invitar*.

## Bueno saber
- Quien tenga el enlace con el código del final puede ver y editar la lista: compartidlo solo en la familia.
- En el plan gratis, Supabase pausa los proyectos tras una semana sin uso. No se pierde nada: se reactiva desde su web.
