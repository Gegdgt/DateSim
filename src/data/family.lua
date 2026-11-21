return {
 minimum=-100,maximum=100,initial=50,strainedBelow=25,separationAt=-30,
 neglectPenalty=20,positiveAt=75,positiveBonus=1,negativeFactor=.5,
 repetition={1,.9,.8},discountPercent=20,
 repeated={
  eris={expression="angry",text="¡Otra vez conmigo! Me gusta tenerte aquí, pero no voy a pelear con una cesta de ropa por tu atención. Ve a ver qué necesitan las demás.",reply="Rudy anota las tareas pendientes. Eris le da un empujón hacia la puerta, sin soltar todavía su mano."},
  sylphiette={expression="worried",text="Hoy hemos tenido tres ratos juntos. Me alegra, Rudy, pero también quiero que Roxy y Eris puedan contar contigo. Compartir la casa incluye compartir tu tiempo.",reply="Sylphiette señala el horario familiar. Rudy añade un recordatorio para hablar con ambas."},
  roxy={expression="worried",text="¿Ya se ha hecho tan tarde? He reservado otra silla para ti sin pensarlo... No quisiera que Sylphiette y Eris sintieran que las dejamos fuera.",reply="Roxy baja la mirada y cierra el libro. Acuerdan revisar las responsabilidades de casa."},
 },
 warnings={
  eris="¡Rudy! Hoy no has reservado ni un momento para mí. Si esto sigue así, dejaré de esperarte con la espada guardada.",
  sylphiette="Puedo ocuparme de muchas cosas, pero no sostener sola nuestra vida. Necesito que mañana reserves tiempo para nosotros.",
  roxy="He vuelto a guardar tus apuntes sin poder hablar contigo. Una investigación no sustituye nuestra relación. No quiero acostumbrarme a tu ausencia.",
 },
 departures={
  eris={expression="angry",lines={"No es por perder un duelo, Rudy. Ya te dije que no iba a seguir esperando mientras elegías dejarme fuera.","Mi espada no puede arreglar esto por los dos. Te devuelvo el anillo. Me marcho porque esta decisión también me pertenece."},exit="Eris deja el anillo frente a Rudy, monta sin pedir ayuda y toma el camino del bosque."},
  sylphiette={expression="worried",lines={"Hablamos de repartir el tiempo y las responsabilidades. Yo cumplí; nuestra hija también siguió esperándote.","No voy a enseñarle que amar significa aceptar cualquier ausencia. Me llevo a nuestra hija. Necesitamos un hogar en el que podamos confiar."},exit="Sylphiette deja el anillo sobre la mesa. Asegura el equipaje de su hija y ambas parten a caballo."},
  roxy={expression="worried",lines={"Puedo aceptar errores y preguntas sin respuesta. Lo que no puedo hacer es escribir yo sola un futuro para los dos.","Esto no es una prueba que puedas aprobar con otra promesa. Te devuelvo el anillo y me marcho. Necesito que respetes esa decisión."},exit="Roxy guarda sus libros, deja el anillo y monta hacia el camino. Recuperar la voz no cambia su decisión."},
 },
 specialOwners={shared_magic="sylphiette",combined_spell="roxy",sword_magic="eris"},
}
