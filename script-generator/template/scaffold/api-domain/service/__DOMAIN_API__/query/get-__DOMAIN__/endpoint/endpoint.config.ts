import { setupProcess } from '../logic/routeSteps.logic';
import { makeTelemetryEndpoint } from '../../../../shared/utils/endpoint-helpers';

export const get__Domain__Endpoint = makeTelemetryEndpoint(setupProcess);
