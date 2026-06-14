import { setupProcess } from '../logic/routeSteps.logic';
import { makeTelemetryEndpoint } from '../../../../shared/utils/endpoint-helpers';

export const create__Domain__Endpoint = makeTelemetryEndpoint(setupProcess);
