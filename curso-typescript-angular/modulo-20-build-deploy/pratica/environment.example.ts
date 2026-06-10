/**
 * EXEMPLO de environment file.
 *
 * Como usar:
 *  1. Crie a pasta `src/environments/` no seu projeto.
 *  2. Copie este arquivo como `environment.ts` (dev) e `environment.prod.ts` (produção),
 *     ajustando os valores em cada um.
 *  3. Sempre importe do `environment.ts` — o Angular troca pelo `.prod.ts`
 *     automaticamente quando você roda `ng build` (via fileReplacements no angular.json).
 *
 * ⚠️ NUNCA coloque segredos aqui (API keys privadas, senhas). Tudo que está
 *    em environment vai parar no bundle, e qualquer um abre o DevTools e vê.
 *    Pra segredos: backend / variável de ambiente do servidor.
 */
export const environment = {
  /** true em prod, false em dev — útil pra ligar/desligar logs, devtools, etc. */
  production: false,

  /** URL base da API que o app consome */
  apiUrl: 'http://localhost:3000',

  /** Liga console.log de debug em pontos estratégicos do app */
  enableLogs: true,

  /** Liga animações pesadas só em dispositivos potentes (exemplo de feature flag) */
  enableHeavyAnimations: true,

  /** Versão do app — útil pra exibir num footer / enviar em telemetria */
  version: '1.0.0-dev',

  /** Endpoints específicos — exemplo da Pokedex */
  endpoints: {
    pokemons: '/pokemon',
    species: '/pokemon-species'
  }
};

/* -------------------------------------------------------------------------- */
/*  Exemplo de versão production (environment.prod.ts):                       */
/* -------------------------------------------------------------------------- */
/*
export const environment = {
  production: true,
  apiUrl: 'https://pokeapi.co/api/v2',
  enableLogs: false,
  enableHeavyAnimations: false,
  version: '1.0.0',
  endpoints: {
    pokemons: '/pokemon',
    species: '/pokemon-species'
  }
};
*/

/* -------------------------------------------------------------------------- */
/*  Uso em qualquer componente / service:                                     */
/* -------------------------------------------------------------------------- */
/*
import { environment } from '../environments/environment';

const url = `${environment.apiUrl}${environment.endpoints.pokemons}`;
if (environment.enableLogs) console.log('[pokeService] GET', url);
*/
