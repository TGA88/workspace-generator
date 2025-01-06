import { InhLogger } from "@inh-lib/common"
import { FastifyBaseLogger } from "fastify"

export default class FastifyLogAdapter implements InhLogger {
  
    private baseLogger: FastifyBaseLogger
    constructor(baseLogger: FastifyBaseLogger) {
      this.baseLogger = baseLogger
    }
    public trace<I>(msg: I | string):InhLogger{
      this.baseLogger.trace(msg)
      return this
    }
    public debug<I>(msg: I | string):InhLogger{
      this.baseLogger.trace(msg)
      return this
    }
    public info<I>(msg: I | string):InhLogger{
      this.baseLogger.trace(msg)
      return this
    }
    public warn<I>(msg: I | string):InhLogger{
      this.baseLogger.trace(msg)
      return this
    }
    public error<I>(msg: I | string):InhLogger{
      this.baseLogger.trace(msg)
      return this
    }
    public fatal<I>(msg: I | string):InhLogger{
      this.baseLogger.trace(msg)
      return this
    }
  
  }