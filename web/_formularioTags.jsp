<div class="card-nueva-valoracion" style="background: #fff; border-radius: 8px; padding: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); margin-bottom: 25px; border: 1px solid #e0e0e0; font-family: 'Segoe UI', Arial, sans-serif;">
    <h3 style="color: #7A1C31; margin-top: 0; border-bottom: 2px solid #7A1C31; padding-bottom: 8px;">? Evaluar Profesor (Banco de Palabras)</h3>
    
    <form action="AgregarValoracionServlet" method="POST">
        <input type="hidden" name="idProfesor" value="<%= request.getParameter("id") %>">
        
        <div style="margin-bottom: 25px; background: #f9f9f9; padding: 15px; border-radius: 6px;">
            <label style="font-size: 1.1em; color: #333;"><strong>1. Calificación General:</strong></label>
            <select name="estrellas" style="padding: 8px; border-radius: 5px; border: 1px solid #ccc; font-size: 1em; margin-left: 10px; cursor: pointer;">
                <option value="5">????? (Excelente)</option>
                <option value="4">???? (Bueno)</option>
                <option value="3">??? (Regular)</option>
                <option value="2">?? (Malo)</option>
                <option value="1">? (Pésimo)</option>
            </select>
        </div>

        <p style="color: #666; font-size: 0.95em; margin-bottom: 20px;"><strong>2. Selecciona las características que mejor describen al profesor:</strong></p>

        <div style="display: flex; flex-direction: column; gap: 25px;">
            
            <div style="border: 1px solid #eee; border-radius: 6px; padding: 15px;">
                <h4 style="margin: 0 0 10px 0; color: #2c3e50;">? 1. Forma de enseñar</h4>
                <div style="margin-bottom: 10px;"><strong style="color: #27ae60; font-size: 0.85em;">ASPECTOS POSITIVOS:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;">
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Explica claramente"> Explica claramente</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Hace las clases interesantes"> Hace las clases interesantes</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Domina el tema"> Domina el tema</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Resuelve dudas"> Resuelve dudas</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Usa buenos ejemplos"> Usa buenos ejemplos</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Explica paso a paso"> Explica paso a paso</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Hace fácil entender temas difíciles"> Hace fácil entender temas...</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Comparte material útil"> Comparte material útil</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Bien organizado"> Bien organizado</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_ensenar" value="Clases dinámicas"> Clases dinámicas</label>
                </div>
                <div><strong style="color: #c0392b; font-size: 0.85em;">ASPECTOS A MEJORAR:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 5px;">
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="Explica muy rápido"> Explica muy rápido</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="Explica poco"> Explica poco</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="Falta profundidad"> Falta profundidad</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="Las explicaciones son confusas"> Las explicaciones son confusas</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="Cambia de tema con frecuencia"> Cambia de tema frecuentemente</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="Da pocos ejemplos"> Da pocos ejemplos</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_ensenar" value="El ritmo es acelerado"> El ritmo es acelerado</label>
                </div>
            </div>

            <div style="border: 1px solid #eee; border-radius: 6px; padding: 15px;">
                <h4 style="margin: 0 0 10px 0; color: #2c3e50;">? 2. Trato con los estudiantes</h4>
                <div style="margin-bottom: 10px;"><strong style="color: #27ae60; font-size: 0.85em;">ASPECTOS POSITIVOS:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;">
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Amable"> Amable</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Respetuoso"> Respetuoso</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Atento"> Atento</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Paciente"> Paciente</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Comprensivo"> Comprensivo</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Accesible"> Accesible</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Escucha a los estudiantes"> Escucha a los estudiantes</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Profesional"> Profesional</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Motivador"> Motivador</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_trato" value="Empático"> Empático</label>
                </div>
                <div><strong style="color: #c0392b; font-size: 0.85em;">ASPECTOS A MEJORAR:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 5px;">
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_trato" value="Poco accesible"> Poco accesible</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_trato" value="Difícil de contactar"> Difícil de contactar</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_trato" value="Responde tarde"> Responde tarde</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_trato" value="Poco paciente"> Poco paciente</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_trato" value="Serio en exceso"> Serio en exceso</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_trato" value="Interacción limitada"> Interacción limitada</label>
                </div>
            </div>

            <div style="border: 1px solid #eee; border-radius: 6px; padding: 15px;">
                <h4 style="margin: 0 0 10px 0; color: #2c3e50;">? 3. Evaluaciones y tareas</h4>
                <div style="margin-bottom: 10px;"><strong style="color: #27ae60; font-size: 0.85em;">ASPECTOS POSITIVOS:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;">
                    <label class="tag-label"><input type="checkbox" name="tags_pos_eval" value="Califica de forma justa"> Califica de forma justa</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_eval" value="Da retroalimentación útil"> Da retroalimentación útil</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_eval" value="Exámenes claros"> Exámenes claros</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_eval" value="Tareas útiles para aprender"> Tareas útiles para aprender</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_eval" value="Criterios claros"> Criterios claros</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_eval" value="Evaluación transparente"> Evaluación transparente</label>
                </div>
                <div><strong style="color: #c0392b; font-size: 0.85em;">ASPECTOS A MEJORAR:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 5px;">
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_eval" value="Exámenes difíciles"> Exámenes difíciles</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_eval" value="Exámenes poco claros"> Exámenes poco claros</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_eval" value="Mucha carga de tareas"> Mucha carga de tareas</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_eval" value="Retroalimentación limitada"> Retroalimentación limitada</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_eval" value="Criterios poco claros"> Criterios poco claros</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_eval" value="Calificación lenta"> Calificación lenta</label>
                </div>
            </div>

            <div style="border: 1px solid #eee; border-radius: 6px; padding: 15px;">
                <h4 style="margin: 0 0 10px 0; color: #2c3e50;">? 4. Organización</h4>
                <div style="margin-bottom: 10px;"><strong style="color: #27ae60; font-size: 0.85em;">ASPECTOS POSITIVOS:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;">
                    <label class="tag-label"><input type="checkbox" name="tags_pos_org" value="Puntual"> Puntual</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_org" value="Organizado"> Organizado</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_org" value="Planea bien las clases"> Planea bien las clases</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_org" value="Cumple el programa"> Cumple el programa</label>
                    <label class="tag-label"><input type="checkbox" name="tags_pos_org" value="Aprovecha bien el tiempo"> Aprovecha bien el tiempo</label>
                </div>
                <div><strong style="color: #c0392b; font-size: 0.85em;">ASPECTOS A MEJORAR:</strong></div>
                <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 5px;">
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_org" value="Impuntual"> Impuntual</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_org" value="Cambia el plan constantemente"> Cambia el plan de imprevisto</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_org" value="Desorganizado"> Desorganizado</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_org" value="Retrasos frecuentes"> Retrasos frecuentes</label>
                    <label class="tag-label-neg"><input type="checkbox" name="tags_neg_org" value="Se desvía del tema"> Se desvía del tema</label>
                </div>
            </div>

        </div>

        <div style="text-align: right; margin-top: 25px;">
            <button type="submit" style="background: #7A1C31; color: white; border: none; padding: 12px 30px; border-radius: 25px; cursor: pointer; font-weight: bold; font-size: 1em; transition: 0.2s;">
                Guardar Puntuación
            </button>
        </div>
    </form>
</div>

<style>
.tag-label {
    display: inline-flex;
    align-items: center;
    background: #eef9f1;
    color: #1e7e34;
    border: 1px solid #c3e6cb;
    padding: 6px 12px;
    border-radius: 16px;
    font-size: 0.9em;
    cursor: pointer;
    user-select: none;
    transition: 0.15s;
}
.tag-label:hover { background: #d4edda; }
.tag-label input, .tag-label-neg input { margin-right: 6px; cursor: pointer; }

.tag-label-neg {
    display: inline-flex;
    align-items: center;
    background: #fdf2f2;
    color: #bd2130;
    border: 1px solid #f5c6cb;
    padding: 6px 12px;
    border-radius: 16px;
    font-size: 0.9em;
    cursor: pointer;
    user-select: none;
    transition: 0.15s;
}
.tag-label-neg:hover { background: #f8d7da; }
</style>